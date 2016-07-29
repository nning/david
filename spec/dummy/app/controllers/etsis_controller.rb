class EtsisController < ActionController::Base
  def show
    head 2.05, content_type: :text
  end

  def update
    head 2.01
  end

  def create
    head 2.04
  end

  def destroy
    head 2.02
  end

  def seg
    show
  end

  def query
    show
  end
end
