# encoding: UTF-8
require 'socket'
require 'uri'
root = File.expand_path(__dir__)
server = TCPServer.new('127.0.0.1', 4567)
puts 'Dashboard: http://localhost:4567'
trap('INT') { server.close; exit }
loop do
  sock = server.accept
  request = sock.gets
  path = request.to_s.split(' ')[1].to_s
  path = path.encode('UTF-8', invalid: :replace, undef: :replace)
  path = path.force_encoding('UTF-8')
  path = URI::DEFAULT_PARSER.unescape(path) rescue path
  path = '/index.html' if path == '/'
  file = root.b + '/'.b + path[1..-1].to_s.b
  if File.file?(file)
    type = case File.extname(file).downcase
           when '.html' then 'text/html; charset=utf-8'
           when '.csv' then 'text/csv; charset=utf-8'
           when '.jpg','.jpeg' then 'image/jpeg'
           when '.png' then 'image/png'
           else 'application/octet-stream'
           end
    body = File.binread(file)
    sock.write("HTTP/1.1 200 OK\r\nContent-Type: #{type}\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n")
    sock.write(body)
  else
    body = 'Not found'
    sock.write("HTTP/1.1 404 Not Found\r\nContent-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n#{body}")
  end
  sock.close
end
