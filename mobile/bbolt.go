package mobile

import (
	"bytes"
	"errors"
	"fmt"

	bolt "go.etcd.io/bbolt"
)

// ErrBucketNotFound is returned if the given bucket does not exist.
var ErrBucketNotFound = errors.New("bucket not found")

// ErrKeyNotFound is returned if the given key does not exist.
var ErrKeyNotFound = errors.New("key not found")

// NewBoltDB creates and opens a database under the directory given by filepath.
func NewBoltDB(filepath string) (*BoltDB, error) {
	db, err := bolt.Open(filepath+"/bolt.db", 0600, nil)
	if err != nil {
		return nil, err
	}

	return &BoltDB{db}, nil
}

// BoltDB wraps bbolt database transactions to provide a simplified api.
type BoltDB struct {
	db *bolt.DB
}

// Path returns the filename of the currently open database.
func (b *BoltDB) Path() string {
	return b.db.Path()
}

// Close releases all database resources.
func (b *BoltDB) Close() {
	b.db.Close()
}

// CreateBucketIfNotExists creates a bucket with the name bucketName if it
// doesn't already exist.
func (b *BoltDB) CreateBucketIfNotExists(bucketName string) error {
	return b.db.Update(func(tx *bolt.Tx) error {
		_, err := tx.CreateBucketIfNotExists([]byte(bucketName))
		if err != nil {
			return fmt.Errorf("create bucket: %s", err)
		}
		return nil
	})
}

// Get returns the value associated with the given key. If the bucket does not
// exist it returns ErrBucketNotFound and if the key does not exist it returns
// ErrKeyNotFound.
func (b *BoltDB) Get(bucket string, key string) (result []byte, err error) {
	err = b.db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte(bucket))
		if b == nil {
			return fmt.Errorf("%q: %w", bucket, ErrBucketNotFound)
		}

		v := b.Get([]byte(key))

		if v == nil {
			return fmt.Errorf("%q: %w", key, ErrKeyNotFound)
		}

		result = make([]byte, len(v))
		copy(result, v)

		return nil
	})
	if err != nil {
		return nil, err
	}
	return result, nil
}

// Put sets the value for the given key in the bucket. If the bucket does not
// exist ErrBucketNotFound is returned.
func (b *BoltDB) Put(bucket string, key string, value []byte) error {
	return b.db.Update(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte(bucket))
		if b == nil {
			return fmt.Errorf("%q: %w", bucket, ErrBucketNotFound)
		}

		return b.Put([]byte(key), value)
	})
}

// GetKeysByPrefix returns a slice containing all keys that match the given
// prefix at the time of the query. The keys are returned as one long utf8 byte
// slice where the individual entries are null separated as gomobile cannot
// currently generate bindings for string slices (see
// https://github.com/golang/go/issues/13445).
func (b *BoltDB) GetKeysByPrefix(bucket string, prefix string) (keys []byte,
	err error) {
	err = b.db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte(bucket))
		if b == nil {
			return fmt.Errorf("%q: %w", bucket, ErrBucketNotFound)
		}

		c := b.Cursor()
		prefix := []byte(prefix)
		for k, _ := c.Seek(prefix); k != nil && bytes.HasPrefix(k, prefix); k, _ = c.Next() {
			keys = append(keys, k...)
			// Separate keys using the null character.
			keys = append(keys, 0)
		}

		return nil
	})
	if err != nil {
		return nil, err
	}
	return keys, nil
}
