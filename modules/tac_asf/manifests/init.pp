class tac_asf {
  package {                    
      "build-essential": ensure => latest;        
      "python": ensure => "2.7.1-2ubuntu1";            
      "python-dev": ensure => "2.7.1-2ubuntu1";        
      "python-setuptools": ensure => "latest";          
    }   
  exec { "easy_install pip":                
      path => "/usr/local/bin:/usr/bin:/bin",          
      refreshonly => true,            
      require => Package["python-setuptools"],          
      subscribe => Package["python-setuptools"],        
    }                      
}                    

package {
  "django":
    ensure => "1.3.7",
    provider => pip;
}
