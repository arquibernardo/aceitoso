class ResourcesController < ApplicationController
  layout 'application'

  def search
        logger.info "search::: > buscando .... "+params[:query].to_s
#    logger.info @resource
   query = params[:query].split.map {|term| "%#{term}%" }
   query=params[:query].sub("Articulo: ", "")
   query=query.sub("Museo: ", "")
   query=query.sub("Ruta: ", "")
   query=query.sub("Hito: ", "")
     @resource_museos=  Museo.where(["nombre LIKE ?", "%"+query+"%"])
     @resource_genericas= Generica.where(["titulo LIKE ?", "%"+query+"%"])
     @resource_piezas= Pieza.where(["nombre LIKE ?", "%"+query+"%"])
     @resource_caminos= Camino.where(["nombre LIKE ?", "%"+query+"%"])
     @resource_hitos= Hito.where(["nombre LIKE ?", "%"+query+"%"])
    
#    logger.info @resource.children
    data=DatosSearch.new
#    data.resultado_html="202"
     data.data_museos=@resource_museos
     data.data_genericas=@resource_genericas
     data.data_piezas=@resource_piezas
     data.data_caminos=@resource_caminos
     data.data_hitos=@resource_hitos
    # @resource.each{|el| logger.info (el.class==Museo)}

      respuesta='/* this is javascript */ '+params[:callback].to_s+'({
      "result":[
      {"mid":"1",
      "name":"Serbia",
      "notable":{"name":"Country"}
      },
      {"mid":"2","name":"Seattle","notable":{"name":"City/Town/Village","id":"/location/citytown"},"lang":"en","score":71.649063},
      {"mid":"3","name":"Sex","notable":{"name":"Route of infection transmission","id":"/medicine/transmission_route"},"lang":"en","score":64.541069},
      {"mid":"4","name":"Seoul","notable":{"name":"City/Town/Village","id":"/location/citytown"},"lang":"en","score":63.484711},
      {"mid":"5","name":"Senegal","notable":{"name":"Country","id":"/location/country"},"lang":"en","score":62.349876}
      ]
      });'
         # logger.info respuesta
            respuesta='/* this is javascript */ '+params[:callback].to_s+'('+data.to_json().to_s+');'
          #logger.info respuesta
            render :text => respuesta
  end
  def busca(id_param)
        resultado=Relacionable.find_by_id(id_param).heir
        
        if [Generica, Pieza, Hito, Camino].include?resultado.class
          html=resultado.descripcion
        elsif resultado.class==Museo
          html=resultado.ficha.descripcion
        end
    return resultado, html
  end

  def fly

        logger.info "consulta suggest por mid > id .... "+params[:id].to_s
      resultado, html=busca(params[:id])      

     #   logger.info museo.ficha.descripcion
      respuesta ='/** this is jsonp **/ '+params[:callback].to_s+'({"id":"'+resultado.id.to_s+'","html":\''+html+'\'});'
                render :text => respuesta
  end
  def show
         respond_to do |format|
 format.html # show.html.erb
end
  end
  def detalla
      resultado, html=busca(params[:id])      

    @resource=resultado
    data=Datos.new
    data.data=@resource
    data.resultado_html=html
    
     
    # respond_to do |format|
 #format.html # show.html.erb
 #format.json {render :text => '{"data":{"attributes":[{"values":[{"name":"Ferdinand Porsche","id":"/en/ferdinand_porsche"}],"name":"Founders","id":"/organization/organization/founders"},{"values":[],"name":"Headquarters","id":"/organization/organization/headquarters"},{"values":[{"name":"Automobile","id":"/en/automobile"}],"name":"Industry","id":"/business/business_operation/industry"},{"values":[],"name":"Equivalent Instances","id":"/base/ontologies/ontology_instance/equivalent_instances"},{"values":[],"name":"Employees and other personnel","id":"/business/employer/employees"},{"values":[{"name":"Porsche 911","id":"/en/porsche_911"},{"name":"Porsche","id":"/m/0h5wrrb"}],"name":"Make(s)","id":"/automotive/company/make_s"}],"name":"Porsche","id":"/en/porsche"},"details_html":"details"}'}
# format.json {render :json =>data.to_json( ) }
  render :text =>data.to_json( ) 
#end
#end
end
class DatosSearch
  attr_accessor  :data_museos,:data_genericas,:data_piezas,:data_hitos,:data_caminos, :resultado_html
    def as_json(options = {})
    {
    :result=>dameMuseos+dameGenericas+dameHitos+dameCaminos
    }
  end
  def dameMuseos
    resp=self.data_museos.map {|mar| {"mid" => mar.predecessor.id.to_s, "name" => mar.nombre_select, "notable"=>'aa'} }
    print resp.class
    resp
  end
  def damePiezas
    resp=self.data_piezas.map {|mar| {"mid" => mar.predecessor.id.to_s, "name" => mar.nombre_select, "notable"=>'aa'} }
    print resp.class
    resp
  end
  def dameHitos
    resp=self.data_hitos.map {|mar| {"mid" => mar.predecessor.id.to_s, "name" => mar.nombre_select, "notable"=>'aa'} }
    print resp.class
    resp
  end
  def dameCaminos
    resp=self.data_caminos.map {|mar| {"mid" => mar.predecessor.id.to_s, "name" => mar.nombre_select, "notable"=>'aa'} }
    print resp.class
    resp
  end
  def dameGenericas
    resp=self.data_genericas.map {|mar| {"mid" => mar.predecessor.id.to_s, "name" => mar.nombre_select, "notable"=>'aa'} }
    print resp.class
    resp
  end

end
class Datos
  attr_accessor   :data, :resultado_html, :coordenadas
  def dameNombre
    if [Museo].include? self.data.class then
      self.data.nombre_select
    elsif [Pieza, Hito, Camino].include? self.data.class then
      self.data.nombre_select
    else
      self.data.nombre_select
    end
  end
    def as_json(options = {})
    {
    :data=>{
    :attributes=>  dameAtributos,
    :name=>dameNombre ,
    :id=>self.data.predecessor.id.to_s
    },
    :details_html=>dameDetails, 
    :coords=>(self.data.class==Museo and !self.data.ficha.x.blank?)? self.data.ficha.x+"x"+self.data.ficha.y : ""


    }
  end
  
  def dameDetails
    titulo="<h1>#{self.data.nombre_relacionable}</h1>"
    respuesta_det=titulo
    respuesta_det<<"<p class='summary'>"
    if (self.data.class==Museo) then
        respuesta_det<<imagen_details(self.data.ficha.imagen) unless self.data.ficha.imagen.blank?
          respuesta_det<<self.data.ficha.descripcion 

else
   if ([Pieza, Generica, Hito, Camino].include?self.data.class)
        respuesta_det<<imagen_details(self.data.imagen) unless self.data.imagen.blank?
        end
          respuesta_det<<self.data.descripcion 
  end
      respuesta_det<<"</p>"
    respuesta_det
   end
  
  def imagen_details url
   "<img class='summary-img' width='150' src='#{url}'>"   
  end
  
  def llena mapa
        self.data.relaciones_origen.each{|rel| nombre="#{dameNombreRelacion(rel)}xxx#{rel.origen.id}" and if !mapa.key?nombre then mapa[nombre]=[rel.fin] else mapa[nombre] << rel.fin end }

  end
  def llenaMuseo mapa
        self.data.piezas.each{|pieza| nombre="Piezas Relacionadasxxxxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[pieza.predecessor] else mapa[nombre] << pieza.predecessor end }
        self.data.entorno.caminos.each{|camino| nombre="Rutas Relacionadasxxxxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[camino.predecessor] else mapa[nombre] << camino.predecessor end }
        self.data.entorno.hitos.each{|hito| nombre="Hitos Relacionadasxxxxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[hito.predecessor] else mapa[nombre] << hito.predecessor end }

  end
  def llenaPieza mapa
         nombre="Se expone enxxx#{self.data.museo.predecessor.id}"
         Rails.logger.warn nombre+" llllllllllll"
         mapa[nombre] = [self.data.museo.predecessor] 
        self.data.genericas.each{|generica| nombre="Articulos relacionadosxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[generica.predecessor] else mapa[nombre] << generica.predecessor end }

  end
  def llenaCamino mapa
         nombre="Cerca dexxx#{self.data.entorno.museo.predecessor.id}"
         Rails.logger.warn nombre+" camino"
         mapa[nombre] = [self.data.entorno.museo.predecessor] 
        self.data.genericas.each{|generica| nombre="Articulos relacionadosxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[generica.predecessor] else mapa[nombre] << generica.predecessor end }

  end
  def llenaHito mapa
         nombre="Cerca dexxx#{self.data.entorno.museo.predecessor.id}"
         Rails.logger.warn nombre+" hito"
         mapa[nombre] = [self.data.entorno.museo.predecessor] 
        self.data.genericas.each{|generica| nombre="Articulos relacionadosxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[generica.predecessor] else mapa[nombre] << generica.predecessor end }

  end
  def llenaGenerica mapa
        self.data.piezas.each{|pieza| nombre="Piezas Relacionadasxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[pieza.predecessor] else mapa[nombre] << pieza.predecessor end }
        self.data.caminos.each{|camino| nombre="Rutas Relacionadasxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[camino.predecessor] else mapa[nombre] << camino.predecessor end }
        self.data.hitos.each{|hito| nombre="Hitos relacionadosxxx#{self.data.id}" and if !mapa.key?nombre then mapa[nombre]=[hito.predecessor] else mapa[nombre] << hito.predecessor end }

  end
  def llena_destinos mapa
        self.data.relaciones_fin.each{|rel| nombre="#{dameNombreRelacionDestino(rel)}xxx#{rel.fin.id}" and if !mapa.key?nombre then mapa[nombre]=[rel.origen] else mapa[nombre] << rel.origen end }

  end
  def dameAtributos
#    if self.data.class==Museo
#      value=self.data.ficha
#    else
#      value=self.data
#    end
#    tanto museo como generica son relacionables ...
    mapa=Hash.new
    llena mapa
    llena_destinos mapa
    if self.data.class==Museo then llenaMuseo mapa end
    if self.data.class==Pieza then llenaPieza mapa end
    if self.data.class==Camino then llenaCamino mapa end
    if self.data.class==Hito then llenaHito mapa end
    if self.data.class==Generica then llenaGenerica mapa end
    
     mapa.map{|k,v|  {:id => k.split("xxx")[1], :name => k.split("xxx")[0], :values=>dameValuesRelacionables(v) }}
     
    #mapa.each { |atr|  {:id => atr.to_s, :name => atr, :values=>dameValuesRelacionables(mapa[atr]) } }
    # por cada atributo obtener los relacionables
    # el atributo es el nombre1 o nombre2 de la relacion.sentido_relacion.nombre_relacion segun su valor creciente del sentido
    
    
    #  atributos.each{|atri| }
    #value.labels.map { |mar| {:id => mar.id.to_s, :name => mar.nombre, :values=>dameValuesMuseos(mar)+dameValuesGenericas(mar)} }
    
  end
  
   def dameValuesRelacionables lista
    lista.map { |relacionable| {:name=>relacionable.heir.nombre_ask,:id=>relacionable.id}}
  end
  
  def dameNombreRelacion rel
    if rel.sentido_relacion.creciente
      rel.sentido_relacion.nombre_relacion.nombre1 
    else
    rel.sentido_relacion.nombre_relacion.nombre2 
    end
    
  end
  def dameNombreRelacionDestino rel
    rel.sentido_relacion.titulo_destino_desde_destino
    
  end
  
  def coincide nombre_atributo, relacion, relaciones
      relaciones.each{|rel| dameNombreRelacion rel unless relacion==rel}
  end
  
  def dameValuesMuseos mar
    mar.fichas.map { |child| {:name=>child.museo.nombre,:id=>child.museo.id.to_s+"-M"}}
  end
  def dameValuesGenericas mar
    mar.genericas.map { |child| {:name=>child.titulo,:id=>child.id.to_s+"-I"}}
  end
end
end