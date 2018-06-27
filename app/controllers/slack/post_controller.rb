class Slack::PostController < ApplicationController
  protect_from_forgery except: :callback

  def callback
    @body = JSON.parse(request.body.read)

    case @body['type']
    when 'url_verification'
      render status: 200, json: {challenge: @body['challenge']}
    when 'event_callback'
      client = Slack::Web::Client.new
      client.chat_postMessage(
        as_user: 'true',
        channel: @body['event']['channel'],
        text: @body['event']['text']
      )
      render status: 200, json: {}
    end
  end
end
