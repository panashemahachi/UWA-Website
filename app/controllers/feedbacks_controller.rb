class FeedbacksController < ApplicationController
before_action :set_feedback, only: [:show, :edit, :update, :destroy]
before_action :authenticate_executive!, only: [:edit, :index, :update, :destroy]


 layout "delegate_dashboard"

  respond_to :html

  def index
    @feedbacks = Feedback.all
    respond_with(@feedbacks)
  end

  def show
    respond_with(@feedback)
  end

  def new
    #@feedback = Feedback.new
    # See the feedback you've given
    @feedback = current_delegate.feedbacks.build
    respond_with(@feedback)
    
  end

  def exec_feedback

    @feedback = Feedback.new
    respond_with(@feedback)
  end

  def edit
  end

  def create

    secret_key = 8238
    @feedback = current_delegate.feedbacks.build(feedback_params)
    @feedback.save
    @projected_case_id = Case.where(:case_sponsor => true).where(:done => true).count + 1
    

    @receiver = Delegate.where(:email => @feedback.receiver).first.id

    eval_type = 1 # Peer feedback

    if (@feedback.exec_secret == secret_key)
      eval_type = 2 # Exec feedback
    end
    Delegate.update_peer_or_exec_scores(eval_type, @projected_case_id, @receiver, @feedback.leadership, @feedback.creativity, @feedback.business_sense, @feedback.presentation_skills, @feedback.overall_contribution )
    

    respond_with(@feedback)
  end

  def update
    @feedback.update(feedback_params)
    respond_with(@feedback)
  end

  def destroy
    @feedback.destroy
    respond_with(@feedback)
  end
  private
  def set_feedback
      @feedback = Feedback.find(params[:id])
    end

    def feedback_params
      params.require(:feedback).permit(:receiver, :good_comments, :improvement_comments, :leadership, :creativity, :overall_contribution, :business_sense, :presentation_skills, :exec_secret, :type)
    end

    # Don't allow delegates to access what they're not supposed to
    def authenticate_executive!
      if not current_admin_user
        raise ActionController::RoutingError.new('Not Found')
    end
  end

end
