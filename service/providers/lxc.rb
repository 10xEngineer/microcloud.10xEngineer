service_provider :lcx do

  # container data
  # 
  # id (hash)
  # state (stored outside)
  # type
  # server/pool reference
  # descriptor (disk size, cgroups, firewall, etc). might come from course-lab-descriptor

  action :prepare do
    # prepare a single container
    # arguments: id, type (what boostrap template to use), server/pool reference (for maintenance purposes), initial descriptor

  end

  action :allocate do
    # allocate prepared container 
    # arguments: id, course_template (how to finish the provisioning)
  end

  action :start do
  end

  action :stop do
  end

  action :status do
    # return run-time information about the container 
    # to-be used as part of API info command
    #
  end

  # TODO whole migration/persistence commands will follow
end
