=begin
This module is based off of Simone 'evilsocket' Margaritelli's replace_file.rb module, but I needed a better way to replace multiple files and map them to extensions.
=end

class ReplaceFile < BetterCap::Proxy::HTTP::Module
  meta(
    'Name'        => 'ReplaceFiles',
    'Description' => 'Replace one or more files being downloaded with a custom one.',
    'Version'     => '1.0.0',
    'Author'      => "Adam Baldwin",
    'License'     => 'GPL3'
  )

  @@replace = Hash.new()

  def self.on_options(opts)
    opts.on( '--replace EXT', 'Extension of the files to replace.' ) do |v|
      str = v.split(':', 2)
      filename = File.expand_path str[1]
      unless File.exists?(filename)
        raise BetterCap::Error, "#{filename} file does not exist."
      end
      @@replace[str[0]] = File.read(filename)
    end

  end

  def initialize
    if @@replace.length == 0 
      raise BetterCap::Error, "No --replace option specified for the proxy module." 
    end
  end

  def on_request( request, response )
    @@replace.each do |extension, payload|
      if request.path.include?(".#{extension}")
        BetterCap::Logger.info "Replacing http://#{request.host}#{request.path}"

        response['Content-Length'] = payload.bytesize
        response.body = payload
        break
      end
    end
  end
end
