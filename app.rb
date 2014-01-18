require 'sinatra'
require 'httparty'

helpers do
  class Client
    include HTTParty
    base_uri 'https://api.travis-ci.org/'
  end

  def serve_svg(path)
    content_type 'image/svg+xml'
    File.read("static/#{path}.svg")
  end

  def travis_status(owner, repo)
    case Client.get("/repos/#{owner}/#{repo}", headers: {
      'Accept' => 'application/json; version=2'
    }).parsed_response['repo']['last_build_state']
    when 'passed' then 'passing'
    when 'failing' then 'failed'
    when 'started' then 'pending'
    when nil then 'unknown'
    else 'error'
    end
  end
end

get '/travis/:owner/:repo.svg' do |owner, repo|
  serve_svg "travis_#{travis_status(owner, repo)}"
end
