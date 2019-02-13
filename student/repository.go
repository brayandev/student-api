package student

import (
	"context"
	"os"

	"github.com/mongodb/mongo-go-driver/bson"

	mgo "gopkg.in/mgo.v2"
)

const (
	studentID = "studentId"
)

// Repository is repository ...
type Repository interface {
	authentication(Login, Password string) error
	save(ctx context.Context, student Student) error
	get(ctx context.Context, id string) (*Student, error)
	delete(ctx context.Context, id string) error
}

// RepositoryImpl implements repository...
type RepositoryImpl struct {
	session *mgo.Session
}

// Session ...
type Session struct {
	session  *mgo.Session
	Database *mgo.Database
}

// NewRepository ...
func NewRepository(session *mgo.Session) *RepositoryImpl {
	return &RepositoryImpl{
		session: session,
	}
}

// NewMongoDB ...
func NewMongoDB(endpoint string) (*mgo.Session, error) {
	var mgoSession *mgo.Session
	if mgoSession == nil {
		var err error
		mgoSession, err = mgo.Dial(endpoint)
		if err != nil {
			return nil, err
		}
	}

	return mgoSession.Clone(), nil
}

func (r *RepositoryImpl) save(ctx context.Context, student Student) error {
	c := r.session.DB(os.Getenv("MONGO_DB_NAME")).C(os.Getenv("MOND_DB_COLLECTION"))
	return c.Insert(student)
}

func (r *RepositoryImpl) get(ctx context.Context, id string) (*Student, error) {
	c := r.session.DB(os.Getenv("MONGO_DB_NAME")).C(os.Getenv("MOND_DB_COLLECTION"))
	var student Student
	err := c.Find(bson.M{studentID: id}).One(&student)
	if err != nil {
		return nil, err
	}
	return &student, nil
}

func (r *RepositoryImpl) delete(ctx context.Context, id string) error {
	c := r.session.DB(os.Getenv("MONGO_DB_NAME")).C(os.Getenv("MOND_DB_COLLECTION"))
	err := c.Remove(bson.M{studentID: id})
	if err != nil {
		return err
	}
	return nil
}

func (r *RepositoryImpl) update(ctx context.Context, id string) error {
	c := r.session.DB(os.Getenv("MONGO_DB_NAME")).C(os.Getenv("MOND_DB_COLLECTION"))
	student, gErr := r.get(ctx, id)
	if gErr != nil {
		return gErr
	}
	return c.Update(student.ID, student)
}

// Authentication ...
func (r *RepositoryImpl) authentication(Login, Password string) error {
	return nil
}
