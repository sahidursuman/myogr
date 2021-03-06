Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :forum_auth, :cookie
  manager.failure_app = SessionsController.action(:new)
end

# Setup Session Serialization
#class Warden::SessionSerializer
#  def serialize(record)
#    [record.class.name, record.id]
#  end
#
#  def deserialize(keys)
#    klass, id = keys
#    klass.where(id: id).first
#  end
#end

Warden::Strategies.add :forum_auth, Forum::Auth

Warden::Strategies.add(:cookie) do
  def valid?
    cookies['pass_hash']
  end

  def authenticate!
    user = User.where member_login_key: cookies['pass_hash']
    user = user.count > 1 ? user.find(cookies['member_id']) : user.first
    if user.present? and user.member_login_key_expire > Time.now.to_i
      success! user
    else
      fail!
    end
  end
end

Warden::Manager.after_authentication do |user, auth, opts|
  auth.env['action_dispatch.cookies']['pass_hash'] = if Time.now.to_i > user.member_login_key_expire
                                                       token = user.generate_remember_token
                                                       token['domain'] = '.ogromno.com'
                                                       token
                                                     else
                                                       {value: user.member_login_key, expires: Time.at(user.member_login_key_expire), domain: '.ogromno.com'}
                                                     end
  auth.env['action_dispatch.cookies']['member_id'] = {value: user.id, expires: 1.year.from_now, domain: '.ogromno.com'}
end

Warden::Manager.before_logout do |user, auth, opts|
  auth.env['action_dispatch.cookies']['pass_hash'] = {expires: 1.day.ago, domain: '.ogromno.com'}
  auth.env['action_dispatch.cookies']['member_id'] = {expires: 1.day.ago, domain: '.ogromno.com'}
  auth.env['action_dispatch.cookies']['session_id'] = {expires: 1.day.ago, domain: '.ogromno.com'}
end
