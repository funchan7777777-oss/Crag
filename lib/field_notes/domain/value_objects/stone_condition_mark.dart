enum StoneConditionMark { crispEdges, warmSlab, dampSeep, windBuffed }

extension StoneConditionMarkCopy on StoneConditionMark {
  String get fieldPhrase {
    switch (this) {
      case StoneConditionMark.crispEdges:
        return 'crisp edges';
      case StoneConditionMark.warmSlab:
        return 'warm slab';
      case StoneConditionMark.dampSeep:
        return 'damp seep';
      case StoneConditionMark.windBuffed:
        return 'wind buffed';
    }
  }

  String get shortCue {
    switch (this) {
      case StoneConditionMark.crispEdges:
        return 'edges holding';
      case StoneConditionMark.warmSlab:
        return 'feet warming';
      case StoneConditionMark.dampSeep:
        return 'watch seams';
      case StoneConditionMark.windBuffed:
        return 'dry wind';
    }
  }
}
