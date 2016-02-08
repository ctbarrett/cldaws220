# based on https://gist.github.com/runemadsen/3905593 
#

require 'mini_magick'
require 'sinatra'

set :bind, '0.0.0.0'

get "/" do
  erb :form
end

post '/save_image' do
  
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]

  original_file_name = "./public/original/#{@filename}"
  resized_file_name = "./public/resized/#{@filename}"

  File.open(original_file_name, 'wb') do |f|
    f.write(file.read)
  end

  image = MiniMagick::Image.open(original_file_name)
  image.resize "50%"
  image.write resized_file_name
  
  erb :show_image
end
