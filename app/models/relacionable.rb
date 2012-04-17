class Relacionable < ActiveRecord::Base
          acts_as_predecessor :exposes=>:nombre_select

       has_many :relaciones_origen,:dependent=>:destroy,:class_name => "Relacion", :foreign_key=>"origen_id"
       has_many :relaciones_fin,:dependent=>:destroy, :class_name => "Relacion", :foreign_key=>"fin_id"

  def nombre_select
    " #{heir.nombre_select}"
  end


end