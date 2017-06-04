module WaitUntil
  def wait_for_thread(thread)
    Timeout.timeout(15) do
      loop until thread.alive? == false
    end
  end
end
