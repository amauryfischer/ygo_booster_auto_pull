class Card < ApplicationRecord
  def init
    @json = JSON.parse self.json
  end
  def name
    init
    @json["name"]
  end
  def image
    init
    client = RestClient.get @json["image_path"]
    img = client.body
    File.open("1.jpg","wb").write img
  end
end
