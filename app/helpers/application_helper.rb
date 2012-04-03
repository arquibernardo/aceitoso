module ApplicationHelper
    def imagentam(modelo,tam)
        if modelo.imagen_url.to_s!='' 
            return image_tag(modelo.imagen_url.to_s,:size=>tam)
        else
            return ''
        end
    end
    def imagen(modelo)
        if modelo.imagen_url.to_s!='' 
            return image_tag(modelo.imagen_url.to_s)
        
        else
            return ''
        end
    end
    
end
