// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPoseRecordCollection on Isar {
  IsarCollection<PoseRecord> get poseRecords => this.collection();
}

const PoseRecordSchema = CollectionSchema(
  name: r'PoseRecord',
  id: 6642823020747038174,
  properties: {
    r'createAt': PropertySchema(
      id: 0,
      name: r'createAt',
      type: IsarType.long,
    ),
    r'poseState': PropertySchema(
      id: 1,
      name: r'poseState',
      type: IsarType.long,
    )
  },
  estimateSize: _poseRecordEstimateSize,
  serialize: _poseRecordSerialize,
  deserialize: _poseRecordDeserialize,
  deserializeProp: _poseRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _poseRecordGetId,
  getLinks: _poseRecordGetLinks,
  attach: _poseRecordAttach,
  version: '3.1.8',
);

int _poseRecordEstimateSize(
  PoseRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _poseRecordSerialize(
  PoseRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.createAt);
  writer.writeLong(offsets[1], object.poseState);
}

PoseRecord _poseRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PoseRecord();
  object.createAt = reader.readLong(offsets[0]);
  object.id = id;
  object.poseState = reader.readLong(offsets[1]);
  return object;
}

P _poseRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _poseRecordGetId(PoseRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _poseRecordGetLinks(PoseRecord object) {
  return [];
}

void _poseRecordAttach(IsarCollection<dynamic> col, Id id, PoseRecord object) {
  object.id = id;
}

extension PoseRecordQueryWhereSort
    on QueryBuilder<PoseRecord, PoseRecord, QWhere> {
  QueryBuilder<PoseRecord, PoseRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PoseRecordQueryWhere
    on QueryBuilder<PoseRecord, PoseRecord, QWhereClause> {
  QueryBuilder<PoseRecord, PoseRecord, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PoseRecordQueryFilter
    on QueryBuilder<PoseRecord, PoseRecord, QFilterCondition> {
  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> createAtEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition>
      createAtGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> createAtLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> createAtBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> poseStateEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'poseState',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition>
      poseStateGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'poseState',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> poseStateLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'poseState',
        value: value,
      ));
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterFilterCondition> poseStateBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'poseState',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PoseRecordQueryObject
    on QueryBuilder<PoseRecord, PoseRecord, QFilterCondition> {}

extension PoseRecordQueryLinks
    on QueryBuilder<PoseRecord, PoseRecord, QFilterCondition> {}

extension PoseRecordQuerySortBy
    on QueryBuilder<PoseRecord, PoseRecord, QSortBy> {
  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> sortByCreateAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createAt', Sort.asc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> sortByCreateAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createAt', Sort.desc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> sortByPoseState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poseState', Sort.asc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> sortByPoseStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poseState', Sort.desc);
    });
  }
}

extension PoseRecordQuerySortThenBy
    on QueryBuilder<PoseRecord, PoseRecord, QSortThenBy> {
  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenByCreateAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createAt', Sort.asc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenByCreateAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createAt', Sort.desc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenByPoseState() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poseState', Sort.asc);
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QAfterSortBy> thenByPoseStateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poseState', Sort.desc);
    });
  }
}

extension PoseRecordQueryWhereDistinct
    on QueryBuilder<PoseRecord, PoseRecord, QDistinct> {
  QueryBuilder<PoseRecord, PoseRecord, QDistinct> distinctByCreateAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createAt');
    });
  }

  QueryBuilder<PoseRecord, PoseRecord, QDistinct> distinctByPoseState() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'poseState');
    });
  }
}

extension PoseRecordQueryProperty
    on QueryBuilder<PoseRecord, PoseRecord, QQueryProperty> {
  QueryBuilder<PoseRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PoseRecord, int, QQueryOperations> createAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createAt');
    });
  }

  QueryBuilder<PoseRecord, int, QQueryOperations> poseStateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'poseState');
    });
  }
}
