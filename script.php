<?php

use Drupal\node\Entity\Node;

$nids = \Drupal::entityQuery('node')
  ->condition('type', 'article')
  ->execute();
  $nodes = Node::loadMultiple($nids);

  foreach($nodes as $node) {
    $node->path->pathauto = 1;
    $node->save();
  }

$nids = \Drupal::entityQuery('taxonomy_term')
  ->condition('vid', 'rubrique')
  ->execute();
$nodes = \Drupal\taxonomy\Entity\Term::loadMultiple($nids);

foreach($nodes as $node) {
  $node->path->pathauto = 1;
  $node->save();
}
