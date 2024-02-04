BEGIN TRANSACTION;

REMOVE NAMESPACE teamo;

DEFINE NAMESPACE teamo;
DEFINE DATABASE teamo;

------------------
--- SCOPES
------------------
DEFINE SCOPE user SESSION 4w
  SIGNUP (
    CREATE user CONTENT {
      name: $name,
      email: $email,
      password: crypto::argon2::generate($password)
    }
  )
  SIGNIN (
    SELECT * FROM user WHERE email = $email && crypto::argon2::compare(password, $password)
  );

------------------
--- TABLE: list
------------------
DEFINE TABLE list SCHEMAFULL
  PERMISSIONS
    FOR create
      FULL
    FOR select, update
      WHERE creator = $auth.id || $auth.id INSIDE sharedWith
    FOR delete
      WHERE creator = $auth.id;
        
DEFINE FIELD creator ON list TYPE option<record<user>> DEFAULT $auth.id; // TODO: change this to VALUE
DEFINE FIELD sharedWith ON list TYPE option<array<record<user>>> DEFAULT [];
DEFINE FIELD name ON list TYPE string;
DEFINE FIELD color ON list TYPE string;
DEFINE FIELD lastModified ON list TYPE option<datetime> DEFAULT time::now();
DEFINE FIELD archived ON list TYPE option<bool> DEFAULT false;
DEFINE FIELD checklist ON list TYPE bool;

-- advanced fields
DEFINE FIELD advanced ON list TYPE bool;
DEFINE FIELD view ON list TYPE option<string> DEFAULT 'list' ASSERT $value INSIDE ['list' , 'timeline'];
DEFINE FIELD timelineResolution ON list TYPE option<string> DEFAULT 'week' ASSERT $value INSIDE ['day', 'week', 'month'];

------------------
--- TABLE: item
------------------
------------------
DEFINE TABLE item SCHEMAFULL
  PERMISSIONS
    FOR create
      FULL
    FOR select, update, delete
      WHERE list.creator = $auth.id || $auth.id INSIDE list.sharedWith;

DEFINE FIELD list ON item TYPE record<list>;
DEFINE FIELD previousItem ON item TYPE option<record<item>>;
DEFINE FIELD name ON item TYPE string;
DEFINE FIELD done ON item TYPE option<bool> DEFAULT false;

-- advanced fields
DEFINE FIELD description ON item TYPE option<string>;
DEFINE FIELD date ON item TYPE option<datetime>;
DEFINE FIELD tags ON item TYPE array<record<tag>> DEFAULT [];
DEFINE FIELD assignee ON item TYPE option<record<user>>;

------------------
--- TABLE: tag
------------------
DEFINE TABLE tag SCHEMAFULL
  PERMISSIONS
    FOR create
      FULL
    FOR select, update, delete
      WHERE list.creator = $auth.id || $auth.id INSIDE list.sharedWith;

DEFINE FIELD list ON tag TYPE record<list>;
DEFINE FIELD name ON tag TYPE string;
DEFINE FIELD color ON tag TYPE string;

-- indexes
DEFINE INDEX variation ON tag COLUMNS list, name, color UNIQUE;

------------------
--- TABLE: user
------------------
DEFINE TABLE user SCHEMAFULL
  PERMISSIONS
    FOR create FULL
    FOR select, update, delete
      WHERE id = $auth.id;

DEFINE FIELD name ON user TYPE string;
DEFINE FIELD email ON user TYPE string ASSERT string::is::email($value);
DEFINE FIELD password ON user TYPE string;

--indexes
DEFINE INDEX uniqeEmail ON user COLUMNS email UNIQUE;

----------------
--- FUNCTIONS
----------------

DEFINE FUNCTION fn::getNextItem($list: record, $previousItem: option<record>) {
  $item = SELECT * FROM item WHERE list = $list && previousItem = $previousItem;

  RETURN if array::len($item) == 0 {
    NONE
  } else {
    $item[0]
  };
};

DEFINE FUNCTION fn::getFirstThreeItems($list: record) {
  $first = fn::getNextItem($list);
  RETURN if $first != NONE {
    $items = [$first];

    $second = fn::getNextItem($list, $first.id);
    RETURN if $second != NONE {
      $items = array::add($items, $second);

      $third = fn::getNextItem($list, $second.id);
      RETURN if $third != NONE {
        array::add($items, $third)
      } else {
        $items
      }
    } else {
      $items
    }
  } else {
    []
  };
};

-----------------
--- DEMO DATA
-----------------

CREATE user CONTENT {
  id: user:balint,
  name: 'Horváth Bálint',
  email: 'horvbalint99@gmail.com',
  password: crypto::argon2::generate('12345678'),
};

CREATE user CONTENT {
  id: user:sztella,
  name: 'Jóna Esztella',
  email: 'jona.esztella@gmail.com',
  password: crypto::argon2::generate('12345678'),
};

CREATE list CONTENT {
  id: list:balintslist,
  creator: user:balint,
  name: 'Test list',
  color: '#3cbd5f',
  checklist: true,
  advanced: false,
};

CREATE list CONTENT {
  id: list:sztellaslist,
  creator: user:balint,
  name: 'Test list',
  color: '#5a42f5',
  checklist: true,
  advanced: false,
};

CREATE item CONTENT {
  id: item:first,
  list: list:balintslist,
  name: 'First item',
};

CREATE item CONTENT {
  id: item:second,
  list: list:balintslist,
  previousItem: item:first,
  name: 'Second item',
};

CREATE item CONTENT {
  id: item:third,
  list: list:balintslist,
  previousItem: item:second,
  name: 'Third item',
};

CREATE item CONTENT {
  id: item:fourth,
  list: list:balintslist,
  previousItem: item:third,
  name: 'Fourth item',
};

CREATE item CONTENT {
  id: item:sfirst,
  list: list:sztellaslist,
  name: 'First item',
};

CREATE item CONTENT {
  id: item:ssecond,
  list: list:sztellaslist,
  previousItem: item:sfirst,
  name: 'Second item',
};

CREATE item CONTENT {
  id: item:sthird,
  list: list:sztellaslist,
  previousItem: item:ssecond,
  name: 'Third item',
};

fn::getNextItem(list:balintslist);
fn::getFirstThreeItems(list:balintslist);

COMMIT TRANSACTION;