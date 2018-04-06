class Tool
  def call_sets
    client = RestClient.get 'https://www.ygohub.com/api/all_sets'
    JSON.parse(client.body)["sets"]
  end

  def list(name = "Legend of Blue Eyes White Dragon")
    encoded_name = URI.encode name
    client = RestClient.get('https://www.ygohub.com/api/set_info?name='+encoded_name)
    res = JSON.parse(client.body)["set"]["language_cards"]["English (world)"]
    puts "there is #{res.count} cards"
    return res
  end

  def card_info(name = "Tri-Horned Dragon")
    encoded_name = URI.encode name
    client = RestClient.get('https://www.ygohub.com/api/card_info?name='+encoded_name)
    res = JSON.parse(client.body)["card"]
  end

  def save(name:,file:)
    File.open(name,"wb").write file
  end

  def booster(name: "Legend of Blue Eyes White Dragon")
    `sudo rm -r -f booster`
    `mkdir booster`
    encoded_name = URI.encode name
    client = RestClient.get('https://www.ygohub.com/api/set_info?name='+encoded_name)
    res = JSON.parse(client.body)["set"]["language_cards"]["English (world)"]
    hash = {
      "Secret Rare" => [], #3%
      "Ultra Rare" => [], #8%
      "Super Rare" => [], #20%
      "Rare" => [], #66%
      "Common" => [],
      "Short Print" => [],
      "Unknown" => []
    }
    res.each do |card|
      hash[card["rarities"][0]].push card["card_name"]
    end
    pull_booster(hash: hash)
    hash
  end

  def pull_booster(hash:)
    random = Random.new.rand 100
    if random < 3
      return pull(array: hash["Secret Rare"], one_more: true, hash: hash)
    elsif random >= 3 && random < 8
      return pull(array: hash["Ultra Rare"], one_more: true, hash: hash)
    elsif random >= 8 && random < 20
      return pull(array: hash["Super Rare"], one_more: true, hash: hash)
    else
      return pull(array: hash["Rare"], one_more: false, hash: hash)
    end
  end

  def pull(array:,one_more:, hash:)
    res = []
    elem = array[Random.new.rand(array.count)]
    if one_more
      elem2 = hash["Rare"][Random.new.rand(hash["Rare"].count)]
      7.times do
        res.push pull_common(hash: hash)
      end
      res.push elem2
      res.push elem
    else
      8.times do
        res.push pull_common(hash: hash)
      end
      res.push elem
    end
    res
    9.times do |i|
      f = File.open("booster/#{i}.jpg","wb")
      path = self.card_info(res[i])["image_path"]
      image = RestClient.get(path).body
      f.write image
      f.close
    end
  end

  def pull_common(hash:)
    random = Random.new.rand 1000
    if random < 5 && hash["Unknown"].count != 0
      return  hash["Unknown"][Random.new.rand(hash["Unknown"].count)]
    elsif random >= 5 && random < 25
      return hash["Short Print"][Random.new.rand(hash["Short Print"].count)]
    else
      return hash["Common"][Random.new.rand(hash["Common"].count)]
    end
  end

end
