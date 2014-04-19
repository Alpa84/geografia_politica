class OpinionsController < ApplicationController
  def new
  end

  def index
    @opinions = Opinion.all
  end

  def create
    @opinion = Opinion.new(opinion_params)
    @opinion.save!
    redirect_to @opinion
    #render text: params[:opinions]['opinion'] + "  esta es tu opinión. Esperamos que estés contento"
  end

  def show
    @opinion = Opinion.find(params[:id])
  end

  private

  def opinion_params
    params.require(:opinion).permit(:mensaje, :autor)
  end
end
