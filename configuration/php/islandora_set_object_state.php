<?php

# php change_state.php -h http://localhost:8080/fedora -u fedora -p fedora -s I
# -t/custom/path/to/tuque -- note, no whitespace allowed between flag and value

$options = getopt("h:u:p:s:t::");
list($fedora_url, $username, $password, $state) = array_values($options);
$tuque = isset($options["t"]) ? $options["t"] : "/var/www/drupal/sites/all/libraries/tuque";
if(! file_exists("$tuque/RepositoryConnection.php") ) throw new Exception('Path to Tuque is invalid.');

# include all php files necessary for tuque
foreach ( glob("$tuque/*.php") as $filename) {
  require_once($filename);
}

# default collections
$pids = array(
  'islandora:audio_collection',
  'islandora:bookCollection',
  'islandora:collectionCModel',
  'islandora:compound_collection',
  'islandora:newspaper_collection',
  'islandora:sp_basic_image_collection',
  'islandora:sp_large_image_collection',
  'islandora:sp_pdf_collection',
);

try {
  # make connection
  $connection = new RepositoryConnection($fedora_url, $username, $password);
  $api = new FedoraApi($connection);
  $repository = new FedoraRepository($api, new simpleCache());

  # set state for default collections
  foreach($pids as $pid) {
    $object = $repository->getObject($pid);
    if($object->state != $state) {
      $repository->api->m->modifyObject( $pid, array("state" => $state) );
    }
  }
} catch (Exception $e) {
  echo $e->getMessage();
  exit(1);
}

exit(0);
