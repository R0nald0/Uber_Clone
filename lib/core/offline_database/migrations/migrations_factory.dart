import 'package:uber/core/offline_database/migrations/migration_V1.dart';
import 'package:uber/core/offline_database/migrations/migrations.dart';

class MigrationsFactory {
   List<Migrations> getCreateMigration() =>[
    MigrationV1()
   ];
   List<Migrations> getUpdateMigration(int versioOld)=>[];
}