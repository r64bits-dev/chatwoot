# loading installation configs
GlobalConfig.clear_cache
ConfigLoader.new.process

## Seeds productions
if Rails.env.production?
  # Setup Onboarding flow
  Redis::Alfred.set(Redis::Alfred::CHATWOOT_INSTALLATION_ONBOARDING, true)
end

## Seeds for Local Development
unless Rails.env.production?

  # Enables creating additional accounts from dashboard
  installation_config = InstallationConfig.find_by(name: 'CREATE_NEW_ACCOUNT_FROM_DASHBOARD')
  installation_config.value = true
  installation_config.save!
  GlobalConfig.clear_cache

  account = Account.create!(
    name: 'Acme Inc'
  )

  secondary_account = Account.create!(
    name: 'Acme Org'
  )

  user = User.new(name: 'John', email: 'john@acme.inc', password: 'Password1!', type: 'SuperAdmin')
  user.skip_confirmation!
  user.save!

  AccountUser.create!(
    account_id: account.id,
    user_id: user.id,
    role: :administrator
  )

  AccountUser.create!(
    account_id: secondary_account.id,
    user_id: user.id,
    role: :administrator
  )

  web_widget = Channel::WebWidget.create!(account: account, website_url: 'https://acme.inc')

  inbox = Inbox.create!(channel: web_widget, account: account, name: 'Acme Support')
  InboxMember.create!(user: user, inbox: inbox)

  contact_inbox = ContactInboxWithContactBuilder.new(
    source_id: user.id,
    inbox: inbox,
    hmac_verified: true,
    contact_attributes: { name: 'jane', email: 'jane@example.com', phone_number: '+2320000' }
  ).perform

  conversation = Conversation.create!(
    account: account,
    inbox: inbox,
    status: :open,
    assignee: user,
    contact: contact_inbox.contact,
    contact_inbox: contact_inbox,
    additional_attributes: {}
  )

  # sample email collect
  Seeders::MessageSeeder.create_sample_email_collect_message conversation

  Message.create!(content: 'Hello', account: account, inbox: inbox, conversation: conversation, sender: contact_inbox.contact,
                  message_type: :incoming)

  # sample location message
  #
  location_message = Message.new(content: 'location', account: account, inbox: inbox, sender: contact_inbox.contact, conversation: conversation,
                                 message_type: :incoming)
  location_message.attachments.new(
    account_id: account.id,
    file_type: 'location',
    coordinates_lat: 37.7893768,
    coordinates_long: -122.3895553,
    fallback_title: 'Bay Bridge, San Francisco, CA, USA'
  )
  location_message.save!

  # sample card
  Seeders::MessageSeeder.create_sample_cards_message conversation
  # input select
  Seeders::MessageSeeder.create_sample_input_select_message conversation
  # form
  Seeders::MessageSeeder.create_sample_form_message conversation
  # articles
  Seeders::MessageSeeder.create_sample_articles_message conversation
  # csat
  Seeders::MessageSeeder.create_sample_csat_collect_message conversation

  CannedResponse.create!(account: account, short_code: 'start', content: 'Hello welcome to chatwoot.')

  Product.create([
                   {
                     name: 'Standard',
                     identifier: 'standard',
                     price: 199.00,
                     product_type: 'Plano',
                     description: 'Plano Standard',
                     details: {
                       number_of_agents: 2,
                       number_of_conversations: 600,
                       extra_conversation_cost: 0.40,
                       extra_agent_cost: 149.00,
                       support_type: 'Suporte por chat, Whatsapp ou e-mail'
                     }
                   },
                   {
                     name: 'Scale',
                     identifier: 'scale',
                     price: 600.00,
                     product_type: 'Plano',
                     description: 'Plano Scale',
                     details: {
                       number_of_agents: 10,
                       number_of_conversations: 2000,
                       extra_conversation_cost: 0.35,
                       extra_agent_cost: 129.00,
                       support_type: 'Suporte por chat, Whatsapp ou e-mail'
                     }
                   },
                   {
                     name: 'Pro',
                     identifier: 'pro',
                     price: 1100.00,
                     product_type: 'Plano',
                     description: 'Plano Pro',
                     details: {
                       number_of_agents: 20,
                       number_of_conversations: 4000,
                       extra_conversation_cost: 0.30,
                       extra_agent_cost: 109.00,
                       support_type: 'Suporte por chat, Whatsapp ou e-mail'
                     }
                   }
                 ])

  AccountPlan.create(account: account, product: Product.find_by(name: 'Standard'))
end
