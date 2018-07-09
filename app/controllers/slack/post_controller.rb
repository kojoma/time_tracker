class Slack::PostController < ApplicationController
  require 'date'

  protect_from_forgery except: :callback

  def callback
    @body = JSON.parse(request.body.read)

    case @body['type']
    when 'url_verification'
      render status: 200, json: {challenge: @body['challenge']}
    when 'event_callback'
      result = handle_event_message(@body['event']['text'])

      if result['handle']
        response_text = register_work_hour(result['params'])
      else
        response_text = result['message']
      end

      @client = Slack::Web::Client.new
      @client.chat_postMessage(
        as_user: 'true',
        channel: @body['event']['channel'],
        text: response_text
      )
      render status: 200, json: {}
    end
  end

  private
    def handle_event_message(message)
      result = {}

      matched = message.match(/(<@.*?>)\s+(\S.*)\s+(\S.*)\s+(\S.*$)/)
      unless matched
        result['handle'] = false
        result['message'] = "not matched message pattern."
        return result
      else
        project = matched[2]
        date = matched[3]
        hour = matched[4]
        params = {
          "project" => project,
          "date" => date,
          "hour" => hour
        }

        result['handle'] = true
        result['params'] = params
        return result
      end
    end

    def register_work_hour(params)
      if valid_params?(params)
        params['date'] = get_date_object_from_param(params['date'])

        @work_hour = WorkHour.new(params)

        if @work_hour.save
          return "work hour saved!"
        else
          logger.warn("failed to save work hour. #{@work_hour.inspect}")
          return "failed to save work hour."
        end
      else
        return "failed to validate."
      end
    end

    def valid_params?(params)
      if params["project"].length == 0
        logger.debug("failed to validate project: #{params["project"].inspect}")
        return false
      end

      unless valid_date?(params["date"])
        logger.debug("failed to validate date: #{params["date"].inspect}")
        return false
      end

      if params["hour"].to_f == 0
        logger.debug("failed to validate hour: #{params["hour"].inspect}")
        return false
      end

      return true
    end

    def valid_date?(str)
      if str == 'today'
        return true
      end

      begin
        @date = Date.parse(str, complete = true)
        return @date ? true : false
      rescue
        return false
      end
    end

    def get_date_object_from_param(str)
      date = nil

      case str
      when 'today' then
        date = Date.today
      else
        date = Date.parse(str, complete = true)
      end

      return date
    end
end
