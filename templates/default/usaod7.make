; Core version
; ------------
; Each makefile should begin by declaring the core version of Drupal that all
; projects should be compatible with.

core = 7.x

; API version
; ------------
; Every makefile needs to declare its Drush Make API version. This version of
; drush make uses API version `2`.

api = 2

; Modules
; --------
projects[admin][version] = "2.0-beta3"
projects[admin][subdir] = contrib

projects[admin_tools][version] = "1.1"
projects[admin_tools][subdir] = contrib

projects[ctools][version] = "1.1"
projects[ctools][subdir] = contrib

projects[devel][version] = "1.3"
projects[devel][subdir] = contrib

projects[views][version] = "3.3"
projects[views][subdir] = contrib

projects[views_bulk_operations][version] = "3.0-rc1"
projects[views_bulk_operations][subdir] = contrib

projects[migrate][version] = "2.4"
projects[migrate][subdir] = contrib

projects[migrate_extras][version] = "2.4"
projects[migrate_extras][subdir] = contrib

projects[office_hours][version] = "1.0"
projects[office_hours][subdir] = contrib

projects[workflow][version] = "1.0"
projects[workflow][subdir] = contrib

projects[entity][version] = "1.0-rc3"
projects[entity][subdir] = contrib

projects[entityreference][version] = "1.0-rc3"
projects[entityreference][subdir] = contrib

projects[features][version] = "1.0"
projects[features][subdir] = contrib

projects[eck][version] = "2.0-beta1"
projects[eck][subdir] = contrib

projects[search_api_solr][version] = "1.0-rc2"
projects[search_api_solr][subdir] = contrib

projects[search_api][version] = "1.2"
projects[search_api][subdir] = contrib

projects[facetapi][version] = "1.1"
projects[facetapi][subdir] = contrib

projects[panels][version] = "3.2"
projects[panels][subdir] = contrib

projects[rules][version] = "2.1"
projects[rules][subdir] = contrib

projects[memcache][version] = "1.0"
projects[memcache][subdir] = contrib

projects[references][version] = "2.0"
projects[references][subdir] = contrib

projects[strongarm][version] = "2.0"
projects[strongarm][subdir] = contrib

projects[revisioning][version] = "1.0"
projects[revisioning][subdir] = contrib

; Custom Modules
: --------
projects[migrate_usaod6][download][type] = "git"
projects[migrate_usaod6][download][url] = "git@bitbucket.org:cdracars/migrate_usaod6.git"
projects[migrate_usaod6][type] = "module"
projects[migrate_usaod6][version] = "1.0"
projects[migrate_usaod6][subdir] = custom

projects[usao_courses_node][download][type] = "git"
projects[usao_courses_node][download][url] = "git@bitbucket.org:cdracars/usao-courses-node.git"
projects[usao_courses_node][type] = "module"
projects[usao_courses_node][version] = "1.0"
projects[usao_courses_node][subdir] = custom

projects[usao_catalog_node][download][type] = "git"
projects[usao_catalog_node][download][url] = "git@bitbucket.org:cdracars/usao-catalog-node.git"
projects[usao_catalog_node][type] = "module"
projects[usao_catalog_node][version] = "1.0"
projects[usao_catalog_node][subdir] = custom

; Themes
; --------
projects[gray-n-green][download][type] = "git"
projects[gray-n-green][download][url] = "git@bitbucket.org:cdracars/gray-n-green.git"
projects[gray-n-green][type] = "theme"
projects[gray-n-green][version] = "1.0"

projects[rubik][version] = "4.0-beta8"

projects[tao][version] = "3.0-beta4"

projects[zen][version] = "5.1"
