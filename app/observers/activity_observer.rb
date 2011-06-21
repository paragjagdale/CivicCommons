class ActivityObserver < ActiveRecord::Observer

  observe :contribution, :conversation, :rating_group

  def after_create(model)
    unless model.is_a?(Contribution)
      a = Activity.new(model)
      a.save
    end
  end

  def after_save(model)
    if model.is_a?(Contribution)
      if model.confirmed && (model.issue || model != model.conversation.contributions.first)
        if Activity.where(item_id: model.id, item_type: 'Contribution').empty?
          a = Activity.new(model)
          a.save
        else
          Activity.update(model)
        end
      end
    else
      Activity.update(model)
    end
  end

  def before_destroy(model)
    Activity.destroy(model)
  end

end
