require "rails_helper"

RSpec.describe "routes Blacklight OAI provider", type: :routing do
  it "routes /catalog/oai to the OAI controller action via GET and POST" do
    catalog_oai_action = { controller: "catalog", action: "oai" }
    expect(get: "/catalog/oai").to route_to catalog_oai_action
    expect(post: "/catalog/oai").to route_to catalog_oai_action
  end
end
