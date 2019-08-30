extension QueryBuilder {
    // MARK: Decode

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .alsoDecode(Pet.self)
    ///         .all()
    ///     print(joined) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - type: New model type `D` to also decode.
    /// - returns: `QueryBuilder` decoding type `(Result, D)`.
    public func alsoDecode<M>(_ type: M.Type) -> QueryBuilder<Database, (Result, M)> where M: Fluent.Model {
        return alsoDecode(M.self, M.entity)
    }
    
    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .alsoDecode(Pet?.self)
    ///         .all()
    ///     print(joined) // Future<[(User, Pet)]>
    ///
    /// - parameters:
    ///     - type: New model type `Optional<D>` to also decode.
    /// - returns: `QueryBuilder` decoding type `(Result, Optional<D>)`.
    public func alsoDecode<M>(_ type: Optional<M>.Type) -> QueryBuilder<Database, (Result, M?)> where M: Fluent.Model {
        return alsoDecode(type, M.entity)
    }

    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .alsoDecode(PetDetail.self, "pets")
    ///         .all()
    ///     print(joined) // Future<[(User, PetDetail)]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to also decode.
    ///     - entity: Entity name of this decodable type.
    /// - returns: `QueryBuilder` decoding type `(Result, D)`.
    public func alsoDecode<D>(_ type: D.Type, _ entity: String) -> QueryBuilder<Database, (Result, D)> where D: Decodable {
        return transformResult { row, conn, result in
            return Database.queryDecode(row, entity: entity, as: D.self, on: conn).map { (result, $0) }
        }
    }
    
    /// Adds an additional type `D` to be decoded when run.
    /// The new result for this query will be a tuple containing the previous result and this new result.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(\Pet.userID, to: \User.id)
    ///         .alsoDecode(PetDetail?.self, "pets")
    ///         .all()
    ///     print(joined) // Future<[(User, PetDetail)]>
    ///
    /// - parameters:
    ///     - type: New decodable type `Optional<D>` to also decode.
    ///     - entity: Entity name of this decodable type.
    /// - returns: `QueryBuilder` decoding type `(Result, Optional<D>)`.
    public func alsoDecode<D>(_ type: Optional<D>.Type, _ entity: String) -> QueryBuilder<Database, (Result, D?)> where D: Decodable {
        return transformResult { row, conn, result in
            return Database.queryDecode(row, entity: entity, as: D.self, on: conn)
                .map { (result, $0) }
                .catchMap { _ in (result, nil) }
        }
    }

    /// Sets the query to decode `Model` type `D` when run. The `Model`'s entity will be used.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(Pet.self)
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to decode.
    /// - returns: `QueryBuilder` decoding type `D`.
    public func decode<Model>(_ type: Model.Type) -> QueryBuilder<Database, Model> where Model: Fluent.Model {
        return decode(data: Model.self, Model.entity)
    }
    
    /// Sets the query to decode `Model` type `D` when run. The `Model`'s entity will be used.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(Pet?.self)
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `Optional<D>` to decode.
    /// - returns: `QueryBuilder` decoding type `Optional<D>`.
    public func decode<Model>(_ type: Optional<Model>.Type) -> QueryBuilder<Database, Model?> where Model: Fluent.Model {
        return decode(data: type, Model.entity)
    }
    
    /// Sets the query to decode `Decodable` type `D` when run. The data will be decoded from the supplied entity.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(data: Pet.self, "pets")
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to decode.
    ///     - entity: Table or collection to decode from.
    /// - returns: `QueryBuilder` decoding type `D`.
    public func decode<D>(data type: D.Type, _ entity: String) -> QueryBuilder<Database, D> where D: Decodable {
        return changeResult { row, conn in
            return Database.queryDecode(row, entity: entity, as: D.self, on: conn)
        }
    }
    
    /// Sets the query to decode `Decodable` type `D` when run. The data will be decoded from the supplied entity.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(data: Pet?.self, "pets")
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `Optional<D>` to decode.
    ///     - entity: Table or collection to decode from.
    /// - returns: `QueryBuilder` decoding type `Optional<D>`.
    public func decode<D>(data type: Optional<D>.Type, _ entity: String) -> QueryBuilder<Database, D?> where D: Decodable {
        return changeResult { row, conn in
            return Database.queryDecode(row, entity: entity, as: D.self, on: conn)
                .map(to: D?.self) { $0 }
                .catchMap { _ in nil }
        }
    }

    /// Sets the query to decode raw output from the database when run.
    ///
    ///     let raw = try User.query(on: req).decodeRaw().all()
    ///     print(raw) // Future<[MySQLColumn: MySQLData]>
    ///
    public func decodeRaw() -> QueryBuilder<Database, Database.Output> {
        return changeResult { output, conn in
            return conn.eventLoop.newSucceededFuture(result: output)
        }
    }
    
    // MARK: Internal
    
    /// Creates a new `QueryBuilder` decoding raw DB output.
    static func raw(entity: String, on conn: Future<Database.Connection>) -> QueryBuilder<Database, Database.Output> {
        return .init(query: Database.query(entity), on: conn) { row, conn in
            return conn.future(row)
        }
    }


    /// Replaces the query result handler with the supplied closure.
    func changeResult<NewResult>(with transformer: @escaping (Database.Output, Database.Connection) -> Future<NewResult>) -> QueryBuilder<Database, NewResult> {
        return .init(query: query, on: connection) { row, conn in
            return transformer(row, conn)
        }
    }

    /// Transforms the previous query result to a new result using the supplied closure.
    func transformResult<NewResult>(with transformer: @escaping (Database.Output, Database.Connection, Result) -> Future<NewResult>) -> QueryBuilder<Database, NewResult> {
        return .init(query: query, on: connection) { row, conn in
            return self.resultTransformer(row, conn).flatMap { result in
                return transformer(row, conn, result)
            }
        }
    }
}

extension QueryBuilder where Result: Model {
    /// Sets the query to decode `Decodable` type `D` when run. This data type will be decoded from
    /// the current Model's entity.
    ///
    ///     let joined = try User.query(on: req)
    ///         .join(Pet.self, field: \.userID, to: \.id)
    ///         .decode(data: Pet.self)
    ///         .all()
    ///     print(joined) // Future<[Pet]>
    ///
    /// - parameters:
    ///     - type: New decodable type `D` to decode.
    /// - returns: `QueryBuilder` decoding type `D`.
    public func decode<D>(data type: D.Type) -> QueryBuilder<Database, D> where D: Decodable {
        return decode(data: D.self, Result.entity)
    }
}
