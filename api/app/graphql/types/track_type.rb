Types::TrackType = GraphQL::ObjectType.define do
  name 'Track'

  field :id, !types.ID
  field :url, !types.String
  field :media_url, !types.String
  field :service, !types.String
  field :media_type, !types.String
  field :title, !types.String
  field :artist, !types.String
  field :album, !types.String
  field :year, !types.String
  field :user, -> { Types::UserType }
end
