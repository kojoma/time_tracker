class Slack::PostController < ApplicationController
  require 'date'

  protect_from_forgery except: :callback

  def callback
    @body = JSON.parse(request.body.read)

    case @body['type']
    when 'url_verification'
      render status: 200, json: {challenge: @body['challenge']}
    when 'event_callback'
      handle_result = handle_received_message(@body['event']['text'])

      @client = Slack::Web::Client.new
      if handle_result['success']
        register_result = register_work_hour(handle_result['params'])

        # post register result message when only necessary
        if register_result['should_post']
          @client.chat_postMessage(
            as_user: 'true',
            channel: @body['event']['channel'],
            text: register_result['message']
          )
        end
      else
        # post failed to handle message
        @client.chat_postMessage(
          as_user: 'true',
          channel: @body['event']['channel'],
          text: handle_result['message']
        )
      end

      render status: 200, json: {}
    end
  end

  private
    def handle_received_message(message)
      result = {}

      matched = message.match(/(<@.*?>)\s+(\S.*)\s+(\S.*)\s+(\S.*$)/)
      unless matched
        result['success'] = false
        result['message'] = "not matched message pattern."
      else
        project = matched[2]
        date = matched[3]
        hour = matched[4]
        params = {
          "project" => project,
          "date" => date,
          "hour" => hour
        }

        result['success'] = true
        result['params'] = params
      end

      return result
    end

    def register_work_hour(params)
      result = {}

      if valid_params?(params)
        params['date'] = get_date_object_from_param(params['date'])

        @work_hour = WorkHour.new(params)

        if @work_hour.save
          result['should_post'] = true
          result['message'] = "work hour saved!"
        else
          logger.warn("failed to save work hour, but not critical error. only output log. #{@work_hour.inspect}")
          result['should_post'] = false
        end
      else
          result['should_post'] = true
          result['message'] = "failed to validate."
      end

      return result
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
