Pod::Spec.new do |s|
  s.name = "LSAuthorizationFramework"
  s.version = "0.1.9"
  s.summary = "A short description of LSAuthorization."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"alex.wu"=>"alex.wu@dianping.com"}
  s.homepage = "https://gitlab.lifesense.com/lego/LSAuthorization.git"
  s.description = "TODO: Add long description of the pod here."
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/LSAuthorizationFramework.framework'
end
