# views/api/v2/accounts/permissions/show.jbuilder

json.partial! 'api/v1/models/account_user', formats: [:json], account_user: account_user
