class Subscription < ActiveRecord::Base
  belongs_to :subscribable, :polymorphic => true
  belongs_to :person

  scope :conversations, where(subscribable_type: 'Conversation')
  scope :issues, where(subscribable_type: 'Issue')

  def self.subscribable?(subscription_type, subscription_id, subscriber)
    subscribable_model = subscription_type.camelize.constantize
    return subscribable_model.include? Subscribable
  end

  def self.subscribe(subscription_type, subscription_id, subscriber)
    if self.subscribable?(subscription_type, subscription_id, subscriber)
      subscribable_model = subscription_type.camelize.constantize
      subscribable_model.find(subscription_id).subscribe(subscriber)
    else
      raise(ArgumentError, "#{model}'s can not be subscribed to.")
    end
  end

  def self.unsubscribe(subscription_type, subscription_id, subscriber)
    if self.subscribable?(subscription_type, subscription_id, subscriber)
      subscribable_model = subscription_type.camelize.constantize
      subscribable_model.find(subscription_id).unsubscribe(subscriber)
    else
      raise(ArgumentError, "#{model}'s can not be subscribed to.")
    end
  end

  def self.create_unless_exists(person, subscribable)
    unless person.subscriptions.collect{|sub| sub.subscribable}.include?(subscribable)
      person.subscriptions.create(subscribable: subscribable)
    end
  end

  def name
    if subscribable.respond_to?(:title)
      subscribable.title
    elsif subscribable.respond_to?(:name)
      subscribable.name
    else
      raise(ArgumentError, "#{subscribable} does not have a valid display attribute")
    end
  end

end
