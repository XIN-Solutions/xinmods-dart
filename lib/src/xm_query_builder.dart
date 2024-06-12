
import 'xm_connection.dart';

typedef XmClauseBuilder = void Function(XmClauseExpression);

class XmQuery {

  XmConnection connection;

  /**
   * Type of document to query for
   */
  String? typeName;

  /**
   * Include inherited types? 
   */
  bool withSubtypes;
  
  /**
   * Contains included scope paths
   */
  List<String> includes;

  /**
   * Contains excluded scope paths
   */
  List<String> excludes;

  /**
   * Optional limit
   */
  int? limit;

  /**
   * Optional record offset.
   */
  int? offset;

  /**
   * Optional where-clause
   */
  XmClauseExpression? whereClause;

  /**
   * How to sort the results
   */
  XmQuerySort? sortBy;

  /**
   * Initialise data-members
   */
  XmQuery({
    required this.connection,
    required this.includes,
    
    this.typeName,
    this.withSubtypes = false,
    this.excludes = const [],
    
    this.whereClause,
    this.limit,
    this.offset,
    this.sortBy,
  });

  /**
   * The where clause
   */
  XmQuery where(XmClauseBuilder builder) {
    this.whereClause = XmRootClauseExpression('where', owner: this);
    builder(this.whereClause!);
    return this;
  }

  /**
   * Build the current state into a xinmods query.
   */
  String build() {
    String qStr = "(query \n";
    
    if (this.typeName != null) {
      qStr += "\t(type ${withSubtypes? 'with-subtypes' : ''} '$typeName')\n";
    }
    
    if (this.offset != null) {
      qStr += "\t(offset $offset)\n";
    }
    if (this.limit != null) {
      qStr += "\t(limit $limit)\n";
    }
    if (this.includes.isNotEmpty || this.excludes.isNotEmpty) {
      qStr += "\t(scopes\n";
      
      for (var scope in includes) {
        qStr += "\t\t(include '$scope')\n";
      }
      
      for (var scope in excludes) {
        qStr += "\t\t(exclude '$scope')\n";
      }
      
      qStr += "\t)\n";
    }
  
    if (whereClause != null) {
      qStr += whereClause!.toQuery();
    }
    
    if (sortBy != null) {
      qStr += "\t(sortby [${sortBy!.field}] ${sortBy!.direction == XmQuerySortDirection.Ascending? 'asc' : 'desc'})\n";
    }
      
    qStr += ")";
    return qStr;
  }
  
}

enum XmQuerySortDirection {
  Ascending,
  Descending
}

class XmQuerySort {
  String field;
  XmQuerySortDirection direction;

  XmQuerySort({
    required this.field,
    this.direction = XmQuerySortDirection.Ascending
  });
}


/**
 * Empty marker class
 */
class XmQueryElement {}

/**
 * Describes an operator
 */
class XmOperator extends XmQueryElement {
  String op;
  String field;
  dynamic value;

  XmOperator({
    required this.op,
    required this.field,
    required this.value
  });
}

class XmRootClauseExpression extends XmClauseExpression {

  XmQuery owner;

  XmRootClauseExpression(super.prefix, {required this.owner});

  String build() {
    return this.owner.build();
  }
}

/**
 * The element that helps build clauses.
 */
class XmClauseExpression extends XmQueryElement {

  XmClauseExpression? parent;
  String prefix;
  List<XmQueryElement> expressions;
  int level;

  /**
   * Initialise data-members
   */
  XmClauseExpression(this.prefix, {this.parent, this.level = 1})
  :
      expressions = []
  ;


  // ------------------------------------------------------------------------------------
  //    Comparison Operators
  // ------------------------------------------------------------------------------------


  XmClauseExpression nop() {
    return this;
  }

  /**
   * Add branching to clause building
   */
  XmClauseExpression ifThenElse(bool flag, XmClauseBuilder thenPath, XmClauseBuilder elsePath) {
    if (flag) {
      thenPath(this);
    }
    else {
      elsePath(this);
    }
    return this;
  }

  XmClauseExpression equals(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'eq', field: field, value: value));
    return this;
  }

  XmClauseExpression equalsIgnoreCase(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'ieq', field: field, value: value));
    return this;
  }

  XmClauseExpression notEquals(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'neq', field: field, value: value));
    return this;
  }

  XmClauseExpression notEqualsIgnoreCase(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'ineq', field: field, value: value));
    return this;
  }

  XmClauseExpression contains(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'contains', field: field, value: value));
    return this;
  }

  XmClauseExpression notContains(String field, dynamic value) {
    this.expressions.add(XmOperator(op: '!contains', field: field, value: value));
    return this;
  }

  XmClauseExpression isNull(String field) {
    this.expressions.add(XmOperator(op: 'null', field: field, value: null));
    return this;
  }

  XmClauseExpression isNotNull(String field) {
    this.expressions.add(XmOperator(op: 'notnull', field: field, value: null));
    return this;
  }

  XmClauseExpression gt(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'gt', field: field, value: value));
    return this;
  }

  XmClauseExpression gte(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'gte', field: field, value: value));
    return this;
  }

  XmClauseExpression lt(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'lt', field: field, value: value));
    return this;
  }

  XmClauseExpression lte(String field, dynamic value) {
    this.expressions.add(XmOperator(op: 'lte', field: field, value: value));
    return this;
  }

  // ------------------------------------------------------------------------------------
  //    Conjunction/Disjunction
  // ------------------------------------------------------------------------------------

  XmClauseExpression end() {
    if (this.parent == null) {
      throw StateError("Can't .end() when there is no parent.");
    }
    return this.parent!;
  }

  /**
   *  Create an AND clause
   */
  XmClauseExpression and() {
    var andClause = XmClauseExpression(
      "and",
      parent: this,
      level: this.level + 1,
    );
    this.expressions.add(andClause);
    return andClause;
  }

  /**
   * Create an OR clause
   */
  XmClauseExpression or() {
    var orClause = XmClauseExpression(
      "or",
      parent: this,
      level: this.level + 1,
    );

    this.expressions.add(orClause);
    return orClause;
  }

  // ------------------------------------------------------------------------------------
  //    To String
  // ------------------------------------------------------------------------------------

  String toQuery() {

    // Convert a value to a string
    toValue(val) {
      if (val == null) {
        return '';
      }
      if (val is String) {
        return " '$val'";
      }
      return " $val";
    }

    if (this.expressions.isEmpty) {
      return '';
    }

    var indent = "\t" * this.level;
    var qPart = "$indent($prefix \n";

    for (var expr in this.expressions) {
      if (expr is XmClauseExpression) {
        qPart += expr.toQuery();
      }
      else if (expr is XmOperator){
        qPart += "$indent\t(${expr.op} [${expr.field}]${toValue(expr.value)})\n";
      }
    }

    qPart += "$indent)\n";
    return qPart;
  }

}