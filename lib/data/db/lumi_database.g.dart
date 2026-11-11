// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lumi_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[{"insert":"\\n"}]'),
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedMeta = const VerificationMeta('pinned');
  @override
  late final GeneratedColumn<bool> pinned = GeneratedColumn<bool>(
    'pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _boardStatusMeta = const VerificationMeta(
    'boardStatus',
  );
  @override
  late final GeneratedColumn<String> boardStatus = GeneratedColumn<String>(
    'board_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('todo'),
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickyXMeta = const VerificationMeta(
    'stickyX',
  );
  @override
  late final GeneratedColumn<double> stickyX = GeneratedColumn<double>(
    'sticky_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickyYMeta = const VerificationMeta(
    'stickyY',
  );
  @override
  late final GeneratedColumn<double> stickyY = GeneratedColumn<double>(
    'sticky_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickyWMeta = const VerificationMeta(
    'stickyW',
  );
  @override
  late final GeneratedColumn<double> stickyW = GeneratedColumn<double>(
    'sticky_w',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickyHMeta = const VerificationMeta(
    'stickyH',
  );
  @override
  late final GeneratedColumn<double> stickyH = GeneratedColumn<double>(
    'sticky_h',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stickyZMeta = const VerificationMeta(
    'stickyZ',
  );
  @override
  late final GeneratedColumn<int> stickyZ = GeneratedColumn<int>(
    'sticky_z',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    body,
    plainText,
    colorValue,
    pinned,
    archived,
    deletedAt,
    collectionId,
    boardStatus,
    dueDate,
    stickyX,
    stickyY,
    stickyW,
    stickyH,
    stickyZ,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    if (data.containsKey('pinned')) {
      context.handle(
        _pinnedMeta,
        pinned.isAcceptableOrUnknown(data['pinned']!, _pinnedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    }
    if (data.containsKey('board_status')) {
      context.handle(
        _boardStatusMeta,
        boardStatus.isAcceptableOrUnknown(
          data['board_status']!,
          _boardStatusMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('sticky_x')) {
      context.handle(
        _stickyXMeta,
        stickyX.isAcceptableOrUnknown(data['sticky_x']!, _stickyXMeta),
      );
    }
    if (data.containsKey('sticky_y')) {
      context.handle(
        _stickyYMeta,
        stickyY.isAcceptableOrUnknown(data['sticky_y']!, _stickyYMeta),
      );
    }
    if (data.containsKey('sticky_w')) {
      context.handle(
        _stickyWMeta,
        stickyW.isAcceptableOrUnknown(data['sticky_w']!, _stickyWMeta),
      );
    }
    if (data.containsKey('sticky_h')) {
      context.handle(
        _stickyHMeta,
        stickyH.isAcceptableOrUnknown(data['sticky_h']!, _stickyHMeta),
      );
    }
    if (data.containsKey('sticky_z')) {
      context.handle(
        _stickyZMeta,
        stickyZ.isAcceptableOrUnknown(data['sticky_z']!, _stickyZMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
      pinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pinned'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      ),
      boardStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_status'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      stickyX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sticky_x'],
      ),
      stickyY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sticky_y'],
      ),
      stickyW: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sticky_w'],
      ),
      stickyH: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sticky_h'],
      ),
      stickyZ: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sticky_z'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String type;
  final String title;
  final String body;
  final String plainText;
  final int? colorValue;
  final bool pinned;
  final bool archived;
  final DateTime? deletedAt;
  final String? collectionId;
  final String boardStatus;
  final DateTime? dueDate;
  final double? stickyX;
  final double? stickyY;
  final double? stickyW;
  final double? stickyH;
  final int? stickyZ;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Item({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.plainText,
    this.colorValue,
    required this.pinned,
    required this.archived,
    this.deletedAt,
    this.collectionId,
    required this.boardStatus,
    this.dueDate,
    this.stickyX,
    this.stickyY,
    this.stickyW,
    this.stickyH,
    this.stickyZ,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['plain_text'] = Variable<String>(plainText);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || collectionId != null) {
      map['collection_id'] = Variable<String>(collectionId);
    }
    map['board_status'] = Variable<String>(boardStatus);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || stickyX != null) {
      map['sticky_x'] = Variable<double>(stickyX);
    }
    if (!nullToAbsent || stickyY != null) {
      map['sticky_y'] = Variable<double>(stickyY);
    }
    if (!nullToAbsent || stickyW != null) {
      map['sticky_w'] = Variable<double>(stickyW);
    }
    if (!nullToAbsent || stickyH != null) {
      map['sticky_h'] = Variable<double>(stickyH);
    }
    if (!nullToAbsent || stickyZ != null) {
      map['sticky_z'] = Variable<int>(stickyZ);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      body: Value(body),
      plainText: Value(plainText),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      pinned: Value(pinned),
      archived: Value(archived),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      collectionId: collectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionId),
      boardStatus: Value(boardStatus),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      stickyX: stickyX == null && nullToAbsent
          ? const Value.absent()
          : Value(stickyX),
      stickyY: stickyY == null && nullToAbsent
          ? const Value.absent()
          : Value(stickyY),
      stickyW: stickyW == null && nullToAbsent
          ? const Value.absent()
          : Value(stickyW),
      stickyH: stickyH == null && nullToAbsent
          ? const Value.absent()
          : Value(stickyH),
      stickyZ: stickyZ == null && nullToAbsent
          ? const Value.absent()
          : Value(stickyZ),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      plainText: serializer.fromJson<String>(json['plainText']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      archived: serializer.fromJson<bool>(json['archived']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      collectionId: serializer.fromJson<String?>(json['collectionId']),
      boardStatus: serializer.fromJson<String>(json['boardStatus']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      stickyX: serializer.fromJson<double?>(json['stickyX']),
      stickyY: serializer.fromJson<double?>(json['stickyY']),
      stickyW: serializer.fromJson<double?>(json['stickyW']),
      stickyH: serializer.fromJson<double?>(json['stickyH']),
      stickyZ: serializer.fromJson<int?>(json['stickyZ']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'plainText': serializer.toJson<String>(plainText),
      'colorValue': serializer.toJson<int?>(colorValue),
      'pinned': serializer.toJson<bool>(pinned),
      'archived': serializer.toJson<bool>(archived),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'collectionId': serializer.toJson<String?>(collectionId),
      'boardStatus': serializer.toJson<String>(boardStatus),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'stickyX': serializer.toJson<double?>(stickyX),
      'stickyY': serializer.toJson<double?>(stickyY),
      'stickyW': serializer.toJson<double?>(stickyW),
      'stickyH': serializer.toJson<double?>(stickyH),
      'stickyZ': serializer.toJson<int?>(stickyZ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Item copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    String? plainText,
    Value<int?> colorValue = const Value.absent(),
    bool? pinned,
    bool? archived,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> collectionId = const Value.absent(),
    String? boardStatus,
    Value<DateTime?> dueDate = const Value.absent(),
    Value<double?> stickyX = const Value.absent(),
    Value<double?> stickyY = const Value.absent(),
    Value<double?> stickyW = const Value.absent(),
    Value<double?> stickyH = const Value.absent(),
    Value<int?> stickyZ = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Item(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    body: body ?? this.body,
    plainText: plainText ?? this.plainText,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    collectionId: collectionId.present ? collectionId.value : this.collectionId,
    boardStatus: boardStatus ?? this.boardStatus,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    stickyX: stickyX.present ? stickyX.value : this.stickyX,
    stickyY: stickyY.present ? stickyY.value : this.stickyY,
    stickyW: stickyW.present ? stickyW.value : this.stickyW,
    stickyH: stickyH.present ? stickyH.value : this.stickyH,
    stickyZ: stickyZ.present ? stickyZ.value : this.stickyZ,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      archived: data.archived.present ? data.archived.value : this.archived,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      boardStatus: data.boardStatus.present
          ? data.boardStatus.value
          : this.boardStatus,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      stickyX: data.stickyX.present ? data.stickyX.value : this.stickyX,
      stickyY: data.stickyY.present ? data.stickyY.value : this.stickyY,
      stickyW: data.stickyW.present ? data.stickyW.value : this.stickyW,
      stickyH: data.stickyH.present ? data.stickyH.value : this.stickyH,
      stickyZ: data.stickyZ.present ? data.stickyZ.value : this.stickyZ,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('plainText: $plainText, ')
          ..write('colorValue: $colorValue, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('collectionId: $collectionId, ')
          ..write('boardStatus: $boardStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('stickyX: $stickyX, ')
          ..write('stickyY: $stickyY, ')
          ..write('stickyW: $stickyW, ')
          ..write('stickyH: $stickyH, ')
          ..write('stickyZ: $stickyZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    body,
    plainText,
    colorValue,
    pinned,
    archived,
    deletedAt,
    collectionId,
    boardStatus,
    dueDate,
    stickyX,
    stickyY,
    stickyW,
    stickyH,
    stickyZ,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.body == this.body &&
          other.plainText == this.plainText &&
          other.colorValue == this.colorValue &&
          other.pinned == this.pinned &&
          other.archived == this.archived &&
          other.deletedAt == this.deletedAt &&
          other.collectionId == this.collectionId &&
          other.boardStatus == this.boardStatus &&
          other.dueDate == this.dueDate &&
          other.stickyX == this.stickyX &&
          other.stickyY == this.stickyY &&
          other.stickyW == this.stickyW &&
          other.stickyH == this.stickyH &&
          other.stickyZ == this.stickyZ &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> body;
  final Value<String> plainText;
  final Value<int?> colorValue;
  final Value<bool> pinned;
  final Value<bool> archived;
  final Value<DateTime?> deletedAt;
  final Value<String?> collectionId;
  final Value<String> boardStatus;
  final Value<DateTime?> dueDate;
  final Value<double?> stickyX;
  final Value<double?> stickyY;
  final Value<double?> stickyW;
  final Value<double?> stickyH;
  final Value<int?> stickyZ;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.plainText = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.boardStatus = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.stickyX = const Value.absent(),
    this.stickyY = const Value.absent(),
    this.stickyW = const Value.absent(),
    this.stickyH = const Value.absent(),
    this.stickyZ = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String type,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.plainText = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.pinned = const Value.absent(),
    this.archived = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.boardStatus = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.stickyX = const Value.absent(),
    this.stickyY = const Value.absent(),
    this.stickyW = const Value.absent(),
    this.stickyH = const Value.absent(),
    this.stickyZ = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? plainText,
    Expression<int>? colorValue,
    Expression<bool>? pinned,
    Expression<bool>? archived,
    Expression<DateTime>? deletedAt,
    Expression<String>? collectionId,
    Expression<String>? boardStatus,
    Expression<DateTime>? dueDate,
    Expression<double>? stickyX,
    Expression<double>? stickyY,
    Expression<double>? stickyW,
    Expression<double>? stickyH,
    Expression<int>? stickyZ,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (plainText != null) 'plain_text': plainText,
      if (colorValue != null) 'color_value': colorValue,
      if (pinned != null) 'pinned': pinned,
      if (archived != null) 'archived': archived,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (collectionId != null) 'collection_id': collectionId,
      if (boardStatus != null) 'board_status': boardStatus,
      if (dueDate != null) 'due_date': dueDate,
      if (stickyX != null) 'sticky_x': stickyX,
      if (stickyY != null) 'sticky_y': stickyY,
      if (stickyW != null) 'sticky_w': stickyW,
      if (stickyH != null) 'sticky_h': stickyH,
      if (stickyZ != null) 'sticky_z': stickyZ,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? title,
    Value<String>? body,
    Value<String>? plainText,
    Value<int?>? colorValue,
    Value<bool>? pinned,
    Value<bool>? archived,
    Value<DateTime?>? deletedAt,
    Value<String?>? collectionId,
    Value<String>? boardStatus,
    Value<DateTime?>? dueDate,
    Value<double?>? stickyX,
    Value<double?>? stickyY,
    Value<double?>? stickyW,
    Value<double?>? stickyH,
    Value<int?>? stickyZ,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      plainText: plainText ?? this.plainText,
      colorValue: colorValue ?? this.colorValue,
      pinned: pinned ?? this.pinned,
      archived: archived ?? this.archived,
      deletedAt: deletedAt ?? this.deletedAt,
      collectionId: collectionId ?? this.collectionId,
      boardStatus: boardStatus ?? this.boardStatus,
      dueDate: dueDate ?? this.dueDate,
      stickyX: stickyX ?? this.stickyX,
      stickyY: stickyY ?? this.stickyY,
      stickyW: stickyW ?? this.stickyW,
      stickyH: stickyH ?? this.stickyH,
      stickyZ: stickyZ ?? this.stickyZ,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (boardStatus.present) {
      map['board_status'] = Variable<String>(boardStatus.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (stickyX.present) {
      map['sticky_x'] = Variable<double>(stickyX.value);
    }
    if (stickyY.present) {
      map['sticky_y'] = Variable<double>(stickyY.value);
    }
    if (stickyW.present) {
      map['sticky_w'] = Variable<double>(stickyW.value);
    }
    if (stickyH.present) {
      map['sticky_h'] = Variable<double>(stickyH.value);
    }
    if (stickyZ.present) {
      map['sticky_z'] = Variable<int>(stickyZ.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('plainText: $plainText, ')
          ..write('colorValue: $colorValue, ')
          ..write('pinned: $pinned, ')
          ..write('archived: $archived, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('collectionId: $collectionId, ')
          ..write('boardStatus: $boardStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('stickyX: $stickyX, ')
          ..write('stickyY: $stickyY, ')
          ..write('stickyW: $stickyW, ')
          ..write('stickyH: $stickyH, ')
          ..write('stickyZ: $stickyZ, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChecklistEntriesTable extends ChecklistEntries
    with TableInfo<$ChecklistEntriesTable, ChecklistEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entryTextMeta = const VerificationMeta(
    'entryText',
  );
  @override
  late final GeneratedColumn<String> entryText = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    entryText,
    done,
    sortOrder,
    parentId,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChecklistEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _entryTextMeta,
        entryText.isAcceptableOrUnknown(data['text']!, _entryTextMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTextMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      entryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $ChecklistEntriesTable createAlias(String alias) {
    return $ChecklistEntriesTable(attachedDatabase, alias);
  }
}

class ChecklistEntry extends DataClass implements Insertable<ChecklistEntry> {
  final String id;
  final String itemId;
  final String entryText;
  final bool done;
  final int sortOrder;
  final String? parentId;
  final DateTime? completedAt;
  const ChecklistEntry({
    required this.id,
    required this.itemId,
    required this.entryText,
    required this.done,
    required this.sortOrder,
    this.parentId,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['text'] = Variable<String>(entryText);
    map['done'] = Variable<bool>(done);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  ChecklistEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChecklistEntriesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      entryText: Value(entryText),
      done: Value(done),
      sortOrder: Value(sortOrder),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory ChecklistEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistEntry(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      entryText: serializer.fromJson<String>(json['entryText']),
      done: serializer.fromJson<bool>(json['done']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'entryText': serializer.toJson<String>(entryText),
      'done': serializer.toJson<bool>(done),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'parentId': serializer.toJson<String?>(parentId),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  ChecklistEntry copyWith({
    String? id,
    String? itemId,
    String? entryText,
    bool? done,
    int? sortOrder,
    Value<String?> parentId = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => ChecklistEntry(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    entryText: entryText ?? this.entryText,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
    parentId: parentId.present ? parentId.value : this.parentId,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  ChecklistEntry copyWithCompanion(ChecklistEntriesCompanion data) {
    return ChecklistEntry(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      entryText: data.entryText.present ? data.entryText.value : this.entryText,
      done: data.done.present ? data.done.value : this.done,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistEntry(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entryText: $entryText, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentId: $parentId, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    entryText,
    done,
    sortOrder,
    parentId,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistEntry &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.entryText == this.entryText &&
          other.done == this.done &&
          other.sortOrder == this.sortOrder &&
          other.parentId == this.parentId &&
          other.completedAt == this.completedAt);
}

class ChecklistEntriesCompanion extends UpdateCompanion<ChecklistEntry> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> entryText;
  final Value<bool> done;
  final Value<int> sortOrder;
  final Value<String?> parentId;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const ChecklistEntriesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.entryText = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.parentId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChecklistEntriesCompanion.insert({
    required String id,
    required String itemId,
    required String entryText,
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.parentId = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       entryText = Value(entryText);
  static Insertable<ChecklistEntry> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? entryText,
    Expression<bool>? done,
    Expression<int>? sortOrder,
    Expression<String>? parentId,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (entryText != null) 'text': entryText,
      if (done != null) 'done': done,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (parentId != null) 'parent_id': parentId,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChecklistEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? entryText,
    Value<bool>? done,
    Value<int>? sortOrder,
    Value<String?>? parentId,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return ChecklistEntriesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      entryText: entryText ?? this.entryText,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
      parentId: parentId ?? this.parentId,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (entryText.present) {
      map['text'] = Variable<String>(entryText.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistEntriesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entryText: $entryText, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('parentId: $parentId, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fireAtMeta = const VerificationMeta('fireAt');
  @override
  late final GeneratedColumn<DateTime> fireAt = GeneratedColumn<DateTime>(
    'fire_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatRuleMeta = const VerificationMeta(
    'repeatRule',
  );
  @override
  late final GeneratedColumn<String> repeatRule = GeneratedColumn<String>(
    'repeat_rule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    entryId,
    fireAt,
    repeatRule,
    status,
    notificationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('fire_at')) {
      context.handle(
        _fireAtMeta,
        fireAt.isAcceptableOrUnknown(data['fire_at']!, _fireAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fireAtMeta);
    }
    if (data.containsKey('repeat_rule')) {
      context.handle(
        _repeatRuleMeta,
        repeatRule.isAcceptableOrUnknown(data['repeat_rule']!, _repeatRuleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      ),
      fireAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fire_at'],
      )!,
      repeatRule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_rule'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String itemId;
  final String? entryId;
  final DateTime fireAt;
  final String repeatRule;
  final String status;
  final int notificationId;
  const Reminder({
    required this.id,
    required this.itemId,
    this.entryId,
    required this.fireAt,
    required this.repeatRule,
    required this.status,
    required this.notificationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    map['fire_at'] = Variable<DateTime>(fireAt);
    map['repeat_rule'] = Variable<String>(repeatRule);
    map['status'] = Variable<String>(status);
    map['notification_id'] = Variable<int>(notificationId);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      itemId: Value(itemId),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      fireAt: Value(fireAt),
      repeatRule: Value(repeatRule),
      status: Value(status),
      notificationId: Value(notificationId),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      fireAt: serializer.fromJson<DateTime>(json['fireAt']),
      repeatRule: serializer.fromJson<String>(json['repeatRule']),
      status: serializer.fromJson<String>(json['status']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'entryId': serializer.toJson<String?>(entryId),
      'fireAt': serializer.toJson<DateTime>(fireAt),
      'repeatRule': serializer.toJson<String>(repeatRule),
      'status': serializer.toJson<String>(status),
      'notificationId': serializer.toJson<int>(notificationId),
    };
  }

  Reminder copyWith({
    String? id,
    String? itemId,
    Value<String?> entryId = const Value.absent(),
    DateTime? fireAt,
    String? repeatRule,
    String? status,
    int? notificationId,
  }) => Reminder(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    entryId: entryId.present ? entryId.value : this.entryId,
    fireAt: fireAt ?? this.fireAt,
    repeatRule: repeatRule ?? this.repeatRule,
    status: status ?? this.status,
    notificationId: notificationId ?? this.notificationId,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      fireAt: data.fireAt.present ? data.fireAt.value : this.fireAt,
      repeatRule: data.repeatRule.present
          ? data.repeatRule.value
          : this.repeatRule,
      status: data.status.present ? data.status.value : this.status,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entryId: $entryId, ')
          ..write('fireAt: $fireAt, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    entryId,
    fireAt,
    repeatRule,
    status,
    notificationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.entryId == this.entryId &&
          other.fireAt == this.fireAt &&
          other.repeatRule == this.repeatRule &&
          other.status == this.status &&
          other.notificationId == this.notificationId);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String?> entryId;
  final Value<DateTime> fireAt;
  final Value<String> repeatRule;
  final Value<String> status;
  final Value<int> notificationId;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.fireAt = const Value.absent(),
    this.repeatRule = const Value.absent(),
    this.status = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required String itemId,
    this.entryId = const Value.absent(),
    required DateTime fireAt,
    this.repeatRule = const Value.absent(),
    this.status = const Value.absent(),
    required int notificationId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       fireAt = Value(fireAt),
       notificationId = Value(notificationId);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? entryId,
    Expression<DateTime>? fireAt,
    Expression<String>? repeatRule,
    Expression<String>? status,
    Expression<int>? notificationId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (entryId != null) 'entry_id': entryId,
      if (fireAt != null) 'fire_at': fireAt,
      if (repeatRule != null) 'repeat_rule': repeatRule,
      if (status != null) 'status': status,
      if (notificationId != null) 'notification_id': notificationId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String?>? entryId,
    Value<DateTime>? fireAt,
    Value<String>? repeatRule,
    Value<String>? status,
    Value<int>? notificationId,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      entryId: entryId ?? this.entryId,
      fireAt: fireAt ?? this.fireAt,
      repeatRule: repeatRule ?? this.repeatRule,
      status: status ?? this.status,
      notificationId: notificationId ?? this.notificationId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (fireAt.present) {
      map['fire_at'] = Variable<DateTime>(fireAt.value);
    }
    if (repeatRule.present) {
      map['repeat_rule'] = Variable<String>(repeatRule.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('entryId: $entryId, ')
          ..write('fireAt: $fireAt, ')
          ..write('repeatRule: $repeatRule, ')
          ..write('status: $status, ')
          ..write('notificationId: $notificationId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    kind,
    path,
    name,
    sizeBytes,
    durationMs,
    metadataJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String itemId;
  final String kind;
  final String path;
  final String name;
  final int sizeBytes;
  final int? durationMs;
  final String? metadataJson;
  final DateTime createdAt;
  const Attachment({
    required this.id,
    required this.itemId,
    required this.kind,
    required this.path,
    required this.name,
    required this.sizeBytes,
    this.durationMs,
    this.metadataJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['kind'] = Variable<String>(kind);
    map['path'] = Variable<String>(path);
    map['name'] = Variable<String>(name);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      kind: Value(kind),
      path: Value(path),
      name: Value(name),
      sizeBytes: Value(sizeBytes),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      kind: serializer.fromJson<String>(json['kind']),
      path: serializer.fromJson<String>(json['path']),
      name: serializer.fromJson<String>(json['name']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'kind': serializer.toJson<String>(kind),
      'path': serializer.toJson<String>(path),
      'name': serializer.toJson<String>(name),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'durationMs': serializer.toJson<int?>(durationMs),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Attachment copyWith({
    String? id,
    String? itemId,
    String? kind,
    String? path,
    String? name,
    int? sizeBytes,
    Value<int?> durationMs = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    DateTime? createdAt,
  }) => Attachment(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    kind: kind ?? this.kind,
    path: path ?? this.path,
    name: name ?? this.name,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      kind: data.kind.present ? data.kind.value : this.kind,
      path: data.path.present ? data.path.value : this.path,
      name: data.name.present ? data.name.value : this.name,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    kind,
    path,
    name,
    sizeBytes,
    durationMs,
    metadataJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.kind == this.kind &&
          other.path == this.path &&
          other.name == this.name &&
          other.sizeBytes == this.sizeBytes &&
          other.durationMs == this.durationMs &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> kind;
  final Value<String> path;
  final Value<String> name;
  final Value<int> sizeBytes;
  final Value<int?> durationMs;
  final Value<String?> metadataJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.path = const Value.absent(),
    this.name = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String itemId,
    required String kind,
    required String path,
    required String name,
    this.sizeBytes = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       kind = Value(kind),
       path = Value(path),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? kind,
    Expression<String>? path,
    Expression<String>? name,
    Expression<int>? sizeBytes,
    Expression<int>? durationMs,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (kind != null) 'kind': kind,
      if (path != null) 'path': path,
      if (name != null) 'name': name,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (durationMs != null) 'duration_ms': durationMs,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? kind,
    Value<String>? path,
    Value<String>? name,
    Value<int>? sizeBytes,
    Value<int?>? durationMs,
    Value<String?>? metadataJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      kind: kind ?? this.kind,
      path: path ?? this.path,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      durationMs: durationMs ?? this.durationMs,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('kind: $kind, ')
          ..write('path: $path, ')
          ..write('name: $name, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('durationMs: $durationMs, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, colorValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final int? colorValue;
  const Tag({required this.id, required this.name, this.colorValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'colorValue': serializer.toJson<int?>(colorValue),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    Value<int?> colorValue = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    colorValue: colorValue.present ? colorValue.value : this.colorValue,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, colorValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorValue == this.colorValue);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> colorValue;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.colorValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorValue != null) 'color_value': colorValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? colorValue,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorValue: $colorValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTagsTable extends ItemTags with TableInfo<$ItemTagsTable, ItemTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, tagId};
  @override
  ItemTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTag(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ItemTagsTable createAlias(String alias) {
    return $ItemTagsTable(attachedDatabase, alias);
  }
}

class ItemTag extends DataClass implements Insertable<ItemTag> {
  final String itemId;
  final String tagId;
  const ItemTag({required this.itemId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  ItemTagsCompanion toCompanion(bool nullToAbsent) {
    return ItemTagsCompanion(itemId: Value(itemId), tagId: Value(tagId));
  }

  factory ItemTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTag(
      itemId: serializer.fromJson<String>(json['itemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  ItemTag copyWith({String? itemId, String? tagId}) =>
      ItemTag(itemId: itemId ?? this.itemId, tagId: tagId ?? this.tagId);
  ItemTag copyWithCompanion(ItemTagsCompanion data) {
    return ItemTag(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTag(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTag &&
          other.itemId == this.itemId &&
          other.tagId == this.tagId);
}

class ItemTagsCompanion extends UpdateCompanion<ItemTag> {
  final Value<String> itemId;
  final Value<String> tagId;
  final Value<int> rowid;
  const ItemTagsCompanion({
    this.itemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTagsCompanion.insert({
    required String itemId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       tagId = Value(tagId);
  static Insertable<ItemTag> custom({
    Expression<String>? itemId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTagsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return ItemTagsCompanion(
      itemId: itemId ?? this.itemId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('folder'),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    colorValue,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final int sortOrder;
  const Collection({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    int? sortOrder,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconName, colorValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.iconName = const Value.absent(),
    required int colorValue,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorValue = Value(colorValue);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<int>? colorValue,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemLinksTable extends ItemLinks
    with TableInfo<$ItemLinksTable, ItemLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceItemIdMeta = const VerificationMeta(
    'sourceItemId',
  );
  @override
  late final GeneratedColumn<String> sourceItemId = GeneratedColumn<String>(
    'source_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _targetItemIdMeta = const VerificationMeta(
    'targetItemId',
  );
  @override
  late final GeneratedColumn<String> targetItemId = GeneratedColumn<String>(
    'target_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES items (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [sourceItemId, targetItemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_item_id')) {
      context.handle(
        _sourceItemIdMeta,
        sourceItemId.isAcceptableOrUnknown(
          data['source_item_id']!,
          _sourceItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceItemIdMeta);
    }
    if (data.containsKey('target_item_id')) {
      context.handle(
        _targetItemIdMeta,
        targetItemId.isAcceptableOrUnknown(
          data['target_item_id']!,
          _targetItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetItemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceItemId, targetItemId};
  @override
  ItemLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemLink(
      sourceItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_item_id'],
      )!,
      targetItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_item_id'],
      )!,
    );
  }

  @override
  $ItemLinksTable createAlias(String alias) {
    return $ItemLinksTable(attachedDatabase, alias);
  }
}

class ItemLink extends DataClass implements Insertable<ItemLink> {
  final String sourceItemId;
  final String targetItemId;
  const ItemLink({required this.sourceItemId, required this.targetItemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_item_id'] = Variable<String>(sourceItemId);
    map['target_item_id'] = Variable<String>(targetItemId);
    return map;
  }

  ItemLinksCompanion toCompanion(bool nullToAbsent) {
    return ItemLinksCompanion(
      sourceItemId: Value(sourceItemId),
      targetItemId: Value(targetItemId),
    );
  }

  factory ItemLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemLink(
      sourceItemId: serializer.fromJson<String>(json['sourceItemId']),
      targetItemId: serializer.fromJson<String>(json['targetItemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceItemId': serializer.toJson<String>(sourceItemId),
      'targetItemId': serializer.toJson<String>(targetItemId),
    };
  }

  ItemLink copyWith({String? sourceItemId, String? targetItemId}) => ItemLink(
    sourceItemId: sourceItemId ?? this.sourceItemId,
    targetItemId: targetItemId ?? this.targetItemId,
  );
  ItemLink copyWithCompanion(ItemLinksCompanion data) {
    return ItemLink(
      sourceItemId: data.sourceItemId.present
          ? data.sourceItemId.value
          : this.sourceItemId,
      targetItemId: data.targetItemId.present
          ? data.targetItemId.value
          : this.targetItemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemLink(')
          ..write('sourceItemId: $sourceItemId, ')
          ..write('targetItemId: $targetItemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sourceItemId, targetItemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemLink &&
          other.sourceItemId == this.sourceItemId &&
          other.targetItemId == this.targetItemId);
}

class ItemLinksCompanion extends UpdateCompanion<ItemLink> {
  final Value<String> sourceItemId;
  final Value<String> targetItemId;
  final Value<int> rowid;
  const ItemLinksCompanion({
    this.sourceItemId = const Value.absent(),
    this.targetItemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemLinksCompanion.insert({
    required String sourceItemId,
    required String targetItemId,
    this.rowid = const Value.absent(),
  }) : sourceItemId = Value(sourceItemId),
       targetItemId = Value(targetItemId);
  static Insertable<ItemLink> custom({
    Expression<String>? sourceItemId,
    Expression<String>? targetItemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceItemId != null) 'source_item_id': sourceItemId,
      if (targetItemId != null) 'target_item_id': targetItemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemLinksCompanion copyWith({
    Value<String>? sourceItemId,
    Value<String>? targetItemId,
    Value<int>? rowid,
  }) {
    return ItemLinksCompanion(
      sourceItemId: sourceItemId ?? this.sourceItemId,
      targetItemId: targetItemId ?? this.targetItemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceItemId.present) {
      map['source_item_id'] = Variable<String>(sourceItemId.value);
    }
    if (targetItemId.present) {
      map['target_item_id'] = Variable<String>(targetItemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemLinksCompanion(')
          ..write('sourceItemId: $sourceItemId, ')
          ..write('targetItemId: $targetItemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LumiDatabase extends GeneratedDatabase {
  _$LumiDatabase(QueryExecutor e) : super(e);
  $LumiDatabaseManager get managers => $LumiDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $ChecklistEntriesTable checklistEntries = $ChecklistEntriesTable(
    this,
  );
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ItemTagsTable itemTags = $ItemTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $ItemLinksTable itemLinks = $ItemLinksTable(this);
  late final ItemsDao itemsDao = ItemsDao(this as LumiDatabase);
  late final ChecklistDao checklistDao = ChecklistDao(this as LumiDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as LumiDatabase);
  late final AttachmentsDao attachmentsDao = AttachmentsDao(
    this as LumiDatabase,
  );
  late final OrganizationDao organizationDao = OrganizationDao(
    this as LumiDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    checklistEntries,
    reminders,
    attachments,
    tags,
    itemTags,
    collections,
    itemLinks,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checklist_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reminders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_links', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String type,
  Value<String> title,
  Value<String> body,
  Value<String> plainText,
  Value<int?> colorValue,
  Value<bool> pinned,
  Value<bool> archived,
  Value<DateTime?> deletedAt,
  Value<String?> collectionId,
  Value<String> boardStatus,
  Value<DateTime?> dueDate,
  Value<double?> stickyX,
  Value<double?> stickyY,
  Value<double?> stickyW,
  Value<double?> stickyH,
  Value<int?> stickyZ,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String> body,
  Value<String> plainText,
  Value<int?> colorValue,
  Value<bool> pinned,
  Value<bool> archived,
  Value<DateTime?> deletedAt,
  Value<String?> collectionId,
  Value<String> boardStatus,
  Value<DateTime?> dueDate,
  Value<double?> stickyX,
  Value<double?> stickyY,
  Value<double?> stickyW,
  Value<double?> stickyH,
  Value<int?> stickyZ,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ItemsTableReferences
    extends BaseReferences<_$LumiDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChecklistEntriesTable, List<ChecklistEntry>>
  _checklistEntriesRefsTable(_$LumiDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.checklistEntries,
        aliasName: 'items__id__checklist_entries__item_id',
      );

  $$ChecklistEntriesTableProcessedTableManager get checklistEntriesRefs {
    final manager = $$ChecklistEntriesTableTableManager(
      $_db,
      $_db.checklistEntries,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _checklistEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
  _remindersRefsTable(_$LumiDatabase db) => MultiTypedResultKey.fromTable(
    db.reminders,
    aliasName: 'items__id__reminders__item_id',
  );

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager(
      $_db,
      $_db.reminders,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttachmentsTable, List<Attachment>>
  _attachmentsRefsTable(_$LumiDatabase db) => MultiTypedResultKey.fromTable(
    db.attachments,
    aliasName: 'items__id__attachments__item_id',
  );

  $$AttachmentsTableProcessedTableManager get attachmentsRefs {
    final manager = $$AttachmentsTableTableManager(
      $_db,
      $_db.attachments,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_attachmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTag>> _itemTagsRefsTable(
    _$LumiDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: 'items__id__item_tags__item_id',
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$LumiDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stickyX => $composableBuilder(
    column: $table.stickyX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stickyY => $composableBuilder(
    column: $table.stickyY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stickyW => $composableBuilder(
    column: $table.stickyW,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stickyH => $composableBuilder(
    column: $table.stickyH,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stickyZ => $composableBuilder(
    column: $table.stickyZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> checklistEntriesRefs(
    Expression<bool> Function($$ChecklistEntriesTableFilterComposer f) f,
  ) {
    final $$ChecklistEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checklistEntries,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChecklistEntriesTableFilterComposer(
            $db: $db,
            $table: $db.checklistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersRefs(
    Expression<bool> Function($$RemindersTableFilterComposer f) f,
  ) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableFilterComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attachmentsRefs(
    Expression<bool> Function($$AttachmentsTableFilterComposer f) f,
  ) {
    final $$AttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$LumiDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stickyX => $composableBuilder(
    column: $table.stickyX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stickyY => $composableBuilder(
    column: $table.stickyY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stickyW => $composableBuilder(
    column: $table.stickyW,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stickyH => $composableBuilder(
    column: $table.stickyH,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stickyZ => $composableBuilder(
    column: $table.stickyZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$LumiDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boardStatus => $composableBuilder(
    column: $table.boardStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get stickyX =>
      $composableBuilder(column: $table.stickyX, builder: (column) => column);

  GeneratedColumn<double> get stickyY =>
      $composableBuilder(column: $table.stickyY, builder: (column) => column);

  GeneratedColumn<double> get stickyW =>
      $composableBuilder(column: $table.stickyW, builder: (column) => column);

  GeneratedColumn<double> get stickyH =>
      $composableBuilder(column: $table.stickyH, builder: (column) => column);

  GeneratedColumn<int> get stickyZ =>
      $composableBuilder(column: $table.stickyZ, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> checklistEntriesRefs<T extends Object>(
    Expression<T> Function($$ChecklistEntriesTableAnnotationComposer a) f,
  ) {
    final $$ChecklistEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checklistEntries,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChecklistEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.checklistEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
    Expression<T> Function($$RemindersTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reminders,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableAnnotationComposer(
            $db: $db,
            $table: $db.reminders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attachmentsRefs<T extends Object>(
    Expression<T> Function($$AttachmentsTableAnnotationComposer a) f,
  ) {
    final $$AttachmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attachments,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttachmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.attachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({
            bool checklistEntriesRefs,
            bool remindersRefs,
            bool attachmentsRefs,
            bool itemTagsRefs,
          })
        > {
  $$ItemsTableTableManager(_$LumiDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String> boardStatus = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<double?> stickyX = const Value.absent(),
                Value<double?> stickyY = const Value.absent(),
                Value<double?> stickyW = const Value.absent(),
                Value<double?> stickyH = const Value.absent(),
                Value<int?> stickyZ = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                type: type,
                title: title,
                body: body,
                plainText: plainText,
                colorValue: colorValue,
                pinned: pinned,
                archived: archived,
                deletedAt: deletedAt,
                collectionId: collectionId,
                boardStatus: boardStatus,
                dueDate: dueDate,
                stickyX: stickyX,
                stickyY: stickyY,
                stickyW: stickyW,
                stickyH: stickyH,
                stickyZ: stickyZ,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> collectionId = const Value.absent(),
                Value<String> boardStatus = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<double?> stickyX = const Value.absent(),
                Value<double?> stickyY = const Value.absent(),
                Value<double?> stickyW = const Value.absent(),
                Value<double?> stickyH = const Value.absent(),
                Value<int?> stickyZ = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                type: type,
                title: title,
                body: body,
                plainText: plainText,
                colorValue: colorValue,
                pinned: pinned,
                archived: archived,
                deletedAt: deletedAt,
                collectionId: collectionId,
                boardStatus: boardStatus,
                dueDate: dueDate,
                stickyX: stickyX,
                stickyY: stickyY,
                stickyW: stickyW,
                stickyH: stickyH,
                stickyZ: stickyZ,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  $$ItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                checklistEntriesRefs = false,
                remindersRefs = false,
                attachmentsRefs = false,
                itemTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (checklistEntriesRefs) db.checklistEntries,
                    if (remindersRefs) db.reminders,
                    if (attachmentsRefs) db.attachments,
                    if (itemTagsRefs) db.itemTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (checklistEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Item,
                          $ItemsTable,
                          ChecklistEntry,
                          $ChecklistEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._checklistEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).checklistEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'item_id',
                          typedResults: items,
                        ),
                      if (remindersRefs)
                        await $_getPrefetchedDataByColumns<
                          Item,
                          $ItemsTable,
                          Reminder,
                          $RemindersTable
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._remindersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'item_id',
                          typedResults: items,
                        ),
                      if (attachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Item,
                          $ItemsTable,
                          Attachment,
                          $AttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._attachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).attachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'item_id',
                          typedResults: items,
                        ),
                      if (itemTagsRefs)
                        await $_getPrefetchedDataByColumns<
                          Item,
                          $ItemsTable,
                          ItemTag,
                          $ItemTagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ItemsTableReferences
                              ._itemTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemTagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'item_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({
        bool checklistEntriesRefs,
        bool remindersRefs,
        bool attachmentsRefs,
        bool itemTagsRefs,
      })
    >;
typedef $$ChecklistEntriesTableCreateCompanionBuilder =
    ChecklistEntriesCompanion Function({
      required String id,
      required String itemId,
      required String entryText,
      Value<bool> done,
      Value<int> sortOrder,
      Value<String?> parentId,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$ChecklistEntriesTableUpdateCompanionBuilder =
    ChecklistEntriesCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> entryText,
      Value<bool> done,
      Value<int> sortOrder,
      Value<String?> parentId,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$ChecklistEntriesTableReferences
    extends
        BaseReferences<_$LumiDatabase, $ChecklistEntriesTable, ChecklistEntry> {
  $$ChecklistEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ItemsTable _itemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('checklist_entries__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChecklistEntriesTableFilterComposer
    extends Composer<_$LumiDatabase, $ChecklistEntriesTable> {
  $$ChecklistEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryText => $composableBuilder(
    column: $table.entryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistEntriesTableOrderingComposer
    extends Composer<_$LumiDatabase, $ChecklistEntriesTable> {
  $$ChecklistEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryText => $composableBuilder(
    column: $table.entryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistEntriesTableAnnotationComposer
    extends Composer<_$LumiDatabase, $ChecklistEntriesTable> {
  $$ChecklistEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryText =>
      $composableBuilder(column: $table.entryText, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChecklistEntriesTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $ChecklistEntriesTable,
          ChecklistEntry,
          $$ChecklistEntriesTableFilterComposer,
          $$ChecklistEntriesTableOrderingComposer,
          $$ChecklistEntriesTableAnnotationComposer,
          $$ChecklistEntriesTableCreateCompanionBuilder,
          $$ChecklistEntriesTableUpdateCompanionBuilder,
          (ChecklistEntry, $$ChecklistEntriesTableReferences),
          ChecklistEntry,
          PrefetchHooks Function({bool itemId})
        > {
  $$ChecklistEntriesTableTableManager(
    _$LumiDatabase db,
    $ChecklistEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> entryText = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChecklistEntriesCompanion(
                id: id,
                itemId: itemId,
                entryText: entryText,
                done: done,
                sortOrder: sortOrder,
                parentId: parentId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String entryText,
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChecklistEntriesCompanion.insert(
                id: id,
                itemId: itemId,
                entryText: entryText,
                done: done,
                sortOrder: sortOrder,
                parentId: parentId,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChecklistEntriesTable, ChecklistEntry>(table),
                  $$ChecklistEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$ChecklistEntriesTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$ChecklistEntriesTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChecklistEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $ChecklistEntriesTable,
      ChecklistEntry,
      $$ChecklistEntriesTableFilterComposer,
      $$ChecklistEntriesTableOrderingComposer,
      $$ChecklistEntriesTableAnnotationComposer,
      $$ChecklistEntriesTableCreateCompanionBuilder,
      $$ChecklistEntriesTableUpdateCompanionBuilder,
      (ChecklistEntry, $$ChecklistEntriesTableReferences),
      ChecklistEntry,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required String itemId,
  Value<String?> entryId,
  required DateTime fireAt,
  Value<String> repeatRule,
  Value<String> status,
  required int notificationId,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<String> itemId,
  Value<String?> entryId,
  Value<DateTime> fireAt,
  Value<String> repeatRule,
  Value<String> status,
  Value<int> notificationId,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$LumiDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('reminders__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$LumiDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$LumiDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fireAt => $composableBuilder(
    column: $table.fireAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$LumiDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<DateTime> get fireAt =>
      $composableBuilder(column: $table.fireAt, builder: (column) => column);

  GeneratedColumn<String> get repeatRule => $composableBuilder(
    column: $table.repeatRule,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, $$RemindersTableReferences),
          Reminder,
          PrefetchHooks Function({bool itemId})
        > {
  $$RemindersTableTableManager(_$LumiDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<DateTime> fireAt = const Value.absent(),
                Value<String> repeatRule = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                itemId: itemId,
                entryId: entryId,
                fireAt: fireAt,
                repeatRule: repeatRule,
                status: status,
                notificationId: notificationId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<String?> entryId = const Value.absent(),
                required DateTime fireAt,
                Value<String> repeatRule = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int notificationId,
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                itemId: itemId,
                entryId: entryId,
                fireAt: fireAt,
                repeatRule: repeatRule,
                status: status,
                notificationId: notificationId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, Reminder>(table),
                  $$RemindersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$RemindersTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$RemindersTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, $$RemindersTableReferences),
      Reminder,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String itemId,
      required String kind,
      required String path,
      required String name,
      Value<int> sizeBytes,
      Value<int?> durationMs,
      Value<String?> metadataJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> kind,
      Value<String> path,
      Value<String> name,
      Value<int> sizeBytes,
      Value<int?> durationMs,
      Value<String?> metadataJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$AttachmentsTableReferences
    extends BaseReferences<_$LumiDatabase, $AttachmentsTable, Attachment> {
  $$AttachmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('attachments__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttachmentsTableFilterComposer
    extends Composer<_$LumiDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$LumiDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$LumiDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (Attachment, $$AttachmentsTableReferences),
          Attachment,
          PrefetchHooks Function({bool itemId})
        > {
  $$AttachmentsTableTableManager(_$LumiDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                itemId: itemId,
                kind: kind,
                path: path,
                name: name,
                sizeBytes: sizeBytes,
                durationMs: durationMs,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String kind,
                required String path,
                required String name,
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                itemId: itemId,
                kind: kind,
                path: path,
                name: name,
                sizeBytes: sizeBytes,
                durationMs: durationMs,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttachmentsTable, Attachment>(table),
                  $$AttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$AttachmentsTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$AttachmentsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (Attachment, $$AttachmentsTableReferences),
      Attachment,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<int?> colorValue,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> colorValue,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$LumiDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTag>> _itemTagsRefsTable(
    _$LumiDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: 'tags__id__item_tags__tag_id',
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$LumiDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$LumiDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$LumiDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool itemTagsRefs})
        > {
  $$TagsTableTableManager(_$LumiDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> colorValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                colorValue: colorValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> colorValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                colorValue: colorValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, Tag>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemTagsRefs) db.itemTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemTagsRefs)
                    await $_getPrefetchedDataByColumns<
                      Tag,
                      $TagsTable,
                      ItemTag,
                      $ItemTagsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._itemTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).itemTagsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'tag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool itemTagsRefs})
    >;
typedef $$ItemTagsTableCreateCompanionBuilder = ItemTagsCompanion Function({
  required String itemId,
  required String tagId,
  Value<int> rowid,
});
typedef $$ItemTagsTableUpdateCompanionBuilder = ItemTagsCompanion Function({
  Value<String> itemId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$ItemTagsTableReferences
    extends BaseReferences<_$LumiDatabase, $ItemTagsTable, ItemTag> {
  $$ItemTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _itemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('item_tags__item_id__items__id');

  $$ItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$LumiDatabase db) =>
      db.tags.createAlias('item_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemTagsTableFilterComposer
    extends Composer<_$LumiDatabase, $ItemTagsTable> {
  $$ItemTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableFilterComposer get itemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableOrderingComposer
    extends Composer<_$LumiDatabase, $ItemTagsTable> {
  $$ItemTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableOrderingComposer get itemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableAnnotationComposer
    extends Composer<_$LumiDatabase, $ItemTagsTable> {
  $$ItemTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableAnnotationComposer get itemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $ItemTagsTable,
          ItemTag,
          $$ItemTagsTableFilterComposer,
          $$ItemTagsTableOrderingComposer,
          $$ItemTagsTableAnnotationComposer,
          $$ItemTagsTableCreateCompanionBuilder,
          $$ItemTagsTableUpdateCompanionBuilder,
          (ItemTag, $$ItemTagsTableReferences),
          ItemTag,
          PrefetchHooks Function({bool itemId, bool tagId})
        > {
  $$ItemTagsTableTableManager(_$LumiDatabase db, $ItemTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ItemTagsCompanion(itemId: itemId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String itemId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => ItemTagsCompanion.insert(
                itemId: itemId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemTagsTable, ItemTag>(table),
                  $$ItemTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$ItemTagsTableReferences._itemIdTable(
                          db,
                        ),
                        referencedColumn: $$ItemTagsTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$ItemTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$ItemTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $ItemTagsTable,
      ItemTag,
      $$ItemTagsTableFilterComposer,
      $$ItemTagsTableOrderingComposer,
      $$ItemTagsTableAnnotationComposer,
      $$ItemTagsTableCreateCompanionBuilder,
      $$ItemTagsTableUpdateCompanionBuilder,
      (ItemTag, $$ItemTagsTableReferences),
      ItemTag,
      PrefetchHooks Function({bool itemId, bool tagId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String> iconName,
      required int colorValue,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconName,
      Value<int> colorValue,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$LumiDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$LumiDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$LumiDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            Collection,
            BaseReferences<_$LumiDatabase, $CollectionsTable, Collection>,
          ),
          Collection,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$LumiDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> iconName = const Value.absent(),
                required int colorValue,
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                colorValue: colorValue,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, Collection>(table),
                  BaseReferences<_$LumiDatabase, $CollectionsTable, Collection>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        Collection,
        BaseReferences<_$LumiDatabase, $CollectionsTable, Collection>,
      ),
      Collection,
      PrefetchHooks Function()
    >;
typedef $$ItemLinksTableCreateCompanionBuilder = ItemLinksCompanion Function({
  required String sourceItemId,
  required String targetItemId,
  Value<int> rowid,
});
typedef $$ItemLinksTableUpdateCompanionBuilder = ItemLinksCompanion Function({
  Value<String> sourceItemId,
  Value<String> targetItemId,
  Value<int> rowid,
});

final class $$ItemLinksTableReferences
    extends BaseReferences<_$LumiDatabase, $ItemLinksTable, ItemLink> {
  $$ItemLinksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItemsTable _sourceItemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('item_links__source_item_id__items__id');

  $$ItemsTableProcessedTableManager get sourceItemId {
    final $_column = $_itemColumn<String>('source_item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ItemsTable _targetItemIdTable(_$LumiDatabase db) =>
      db.items.createAlias('item_links__target_item_id__items__id');

  $$ItemsTableProcessedTableManager get targetItemId {
    final $_column = $_itemColumn<String>('target_item_id')!;

    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_targetItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemLinksTableFilterComposer
    extends Composer<_$LumiDatabase, $ItemLinksTable> {
  $$ItemLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableFilterComposer get sourceItemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableFilterComposer get targetItemId {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemLinksTableOrderingComposer
    extends Composer<_$LumiDatabase, $ItemLinksTable> {
  $$ItemLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableOrderingComposer get sourceItemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableOrderingComposer get targetItemId {
    final $$ItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableOrderingComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemLinksTableAnnotationComposer
    extends Composer<_$LumiDatabase, $ItemLinksTable> {
  $$ItemLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ItemsTableAnnotationComposer get sourceItemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ItemsTableAnnotationComposer get targetItemId {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.targetItemId,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemLinksTableTableManager
    extends
        RootTableManager<
          _$LumiDatabase,
          $ItemLinksTable,
          ItemLink,
          $$ItemLinksTableFilterComposer,
          $$ItemLinksTableOrderingComposer,
          $$ItemLinksTableAnnotationComposer,
          $$ItemLinksTableCreateCompanionBuilder,
          $$ItemLinksTableUpdateCompanionBuilder,
          (ItemLink, $$ItemLinksTableReferences),
          ItemLink,
          PrefetchHooks Function({bool sourceItemId, bool targetItemId})
        > {
  $$ItemLinksTableTableManager(_$LumiDatabase db, $ItemLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sourceItemId = const Value.absent(),
                Value<String> targetItemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemLinksCompanion(
                sourceItemId: sourceItemId,
                targetItemId: targetItemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceItemId,
                required String targetItemId,
                Value<int> rowid = const Value.absent(),
              }) => ItemLinksCompanion.insert(
                sourceItemId: sourceItemId,
                targetItemId: targetItemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemLinksTable, ItemLink>(table),
                  $$ItemLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sourceItemId = false, targetItemId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.sourceItemId,
                            referencedTable: $$ItemLinksTableReferences
                                ._sourceItemIdTable(db),
                            referencedColumn: $$ItemLinksTableReferences
                                ._sourceItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (targetItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.targetItemId,
                            referencedTable: $$ItemLinksTableReferences
                                ._targetItemIdTable(db),
                            referencedColumn: $$ItemLinksTableReferences
                                ._targetItemIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ItemLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$LumiDatabase,
      $ItemLinksTable,
      ItemLink,
      $$ItemLinksTableFilterComposer,
      $$ItemLinksTableOrderingComposer,
      $$ItemLinksTableAnnotationComposer,
      $$ItemLinksTableCreateCompanionBuilder,
      $$ItemLinksTableUpdateCompanionBuilder,
      (ItemLink, $$ItemLinksTableReferences),
      ItemLink,
      PrefetchHooks Function({bool sourceItemId, bool targetItemId})
    >;

class $LumiDatabaseManager {
  final _$LumiDatabase _db;
  $LumiDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$ChecklistEntriesTableTableManager get checklistEntries =>
      $$ChecklistEntriesTableTableManager(_db, _db.checklistEntries);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db, _db.itemTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$ItemLinksTableTableManager get itemLinks =>
      $$ItemLinksTableTableManager(_db, _db.itemLinks);
}
