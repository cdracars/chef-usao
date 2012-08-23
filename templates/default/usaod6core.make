; DRUPAL VERSION
core = 6.x

; API version
; ------------
; Every makefile needs to declare its Drush Make API version. This version of
; drush make uses API version `2`.
api = 2

; CORE MODULES
; Pressflow 6.x core:
projects[pressflow][type] = "core"
projects[pressflow][download][type] = "git"
projects[pressflow][download][url] = "https://github.com/pressflow/6.git"
