define g10b::job(
  $project     = $module_name,
  $jobname     = $title,
  $description = $title,
  $git_url     = undef,
  $git_branch  = 'master',
  $template    = undef,
){
  include ::jenkins

  jenkins::job {$jobname:
    config      => template("${module_name}/${template}"), 
  }

}