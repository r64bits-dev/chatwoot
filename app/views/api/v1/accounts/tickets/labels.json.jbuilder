json.array! @labels do |label|
  json.id label.id
  json.title label.title
  json.color label.color
  json.totalUsedCount label.usage_count
end
