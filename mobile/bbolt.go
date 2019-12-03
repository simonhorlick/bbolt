package mobile

import (
	"fmt"
	"log"

	bolt "go.etcd.io/bbolt"
)

func NewBoltDB(filepath string) *BoltDB {
	db, err := bolt.Open(filepath+"/bolt.db", 0600, nil)
	if err != nil {
		log.Fatal(err)
	}

	return &BoltDB{db}
}

type BoltDB struct {
	db *bolt.DB
}

func (b *BoltDB) Path() string {
	return b.db.Path()
}

func (b *BoltDB) Close() {
	b.db.Close()
}

func (b *BoltDB) CreateBucketIfNotExists(bucketName string) {
	err := b.db.Update(func(tx *bolt.Tx) error {
		_, err := tx.CreateBucketIfNotExists([]byte(bucketName))
		if err != nil {
			return fmt.Errorf("create bucket: %s", err)
		}
		return nil
	})
	if err != nil {
		fmt.Printf("failed to create bucket: %v\n", err)
	}
}

func (b *BoltDB) GetKey(bucket string, key string) (result []byte) {
	err := b.db.View(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte(bucket))
		if b == nil {
			return fmt.Errorf("bucket does not exist: %s", bucket)
		}
		v := b.Get([]byte(key))
		if v == nil {
			fmt.Printf("key %s not found\n", key)
			result = nil
		} else {
			result = make([]byte, len(v))
			copy(result, v)
		}
		return nil
	})
	if err != nil {
		fmt.Printf("error fetching key: %v\n", err)
		return nil
	}
	return result
}

func (b *BoltDB) PutKey(bucket string, key string, value []byte) {
	err := b.db.Update(func(tx *bolt.Tx) error {
		b := tx.Bucket([]byte(bucket))
		if b == nil {
			return fmt.Errorf("bucket does not exist: %s", bucket)
		}
		err := b.Put([]byte(key), value)
		return err
	})
	if err != nil {
		fmt.Printf("error storing key: %v\n", err)
	}
}
