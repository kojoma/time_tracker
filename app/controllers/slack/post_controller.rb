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

    matched = message.match(/(<@.*?>)\s+(\S.*)\s+(\S.*)\s+([1-9]$|1\d$|2[0-4]$)/)
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

    if params["hour"].to_i == 0
      logger.debug("failed to validate hour: #{params["hour"].inspect}")
      return false
    end

    return true
  end

  def valid_date?(str)
    begin
      y, m, d = extract_ymd(str)
      return Date.valid_date?(y, m, d)
    rescue
      return false
    end
  end

  def extract_ymd(str)
    match_slash = str.match(/(^\d{4})\/(\d{1}|\d{2})\/(\d{2}$|\d{1}$)/)
    if match_slash
      logger.debug("date matched slash pattern.")
      return str.split("/").map(&:to_i)
    end

    match_hyphen = str.match(/(^\d{4})-(\d{1}|\d{2})-(\d{1}$|\d{2}$)/)
    if match_hyphen
      logger.debug("date matched hyphen pattern.")
      return str.split("-").map(&:to_i)
    end

    return 0, 0, 0
  end
end
