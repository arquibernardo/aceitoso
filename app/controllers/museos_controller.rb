class MuseosController < ApplicationController
    def index
        @museos=Museo.all
    end
    def new
        @museo=Museo.new
    end
    def create
        @museo=Museo.create(params[:museo])
        @museo.save
        redirect_to @museo
    end
    def show
        @museo=Museo.find(params[:id])
    end
    def edit
        @museo=Museo.find(params[:id])
    end

    def update
        @museo = Museo.find(params[:id])

        respond_to do |format|
            if @museo.update_attributes(params[:museo])
                format.html { redirect_to @museo, :notice => 'Informacion actualizada' }
            else
                format.html { render :action => "edit"}
            end
        end
    end
    def destroy
    @museo = Museo.find(params[:id])
    @museo.destroy

    respond_to do |format|
      format.html { redirect_to museos_url }
    end
    end

end
