class Matier {
  int? matiereId;
  String matiereName;
  double matiereCoef;
  Matier(this.matiereName, this.matiereCoef, [this.matiereId]);
  factory Matier.fromJson(Map<String, dynamic> json) {
    return Matier(
      json['matiereName'],
      json['matiereCoef'],
      json['matiereId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matiereName': matiereName,
      'matiereCoef': matiereCoef,
      'matiereId': matiereId,
    };
  }

  @override
  String toString() {
    return matiereName;
  }
}
