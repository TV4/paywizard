defmodule Singula.Telemetry do
  require Logger

  def attach_singula_request_handler do
    :telemetry.attach("singula-reqeust-handler", [:singula, :request], &handle_event/4, nil)
  end

  def attach_singula_response_handler do
    :telemetry.attach("singula-response-handler", [:singula, :response], &handle_event/4, nil)
  end

  def attach_librato_response_handler do
    :telemetry.attach("librato-response-handler", [:singula, :response, :time], &handle_event/4, nil)
  end

  def emit_request_event(request) do
    :telemetry.execute([:singula, :request], %{request: request})
  end

  def emit_response_event(response) do
    :telemetry.execute([:singula, :response], %{response: response})
  end

  def emit_response_time(name, time) do
    :telemetry.execute([:singula, :response, :time], %{time: time}, %{name: name})
  end

  def handle_event([:singula, :request], %{request: request}, _meta_data, _config) do
    Logger.debug("Singula request: #{inspect(request)}")
  end

  def handle_event([:singula, :response], %{response: response}, _meta_data, _config) do
    Logger.debug("Singula response: #{inspect(response)}")
  end

  def handle_event([:singula, :response, :time], %{time: time}, %{name: name}, _config) do
    Logger.info("measure#singula.#{name}.time=#{time}ms count#singula.#{name}.count=1")
  end

  def handle_event(_event, _measurement, _meta_data, _config), do: nil
end
