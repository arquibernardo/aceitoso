class Evento < ActiveRecord::Base
     mount_uploader :imagen,ImagenUploader
     belongs_to :museo
end
