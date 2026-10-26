import '../domain/information_item.dart';
import 'local_information_data_source.dart';

class InformationRepository {
  InformationRepository({LocalInformationDataSource? dataSource})
    : _dataSource = dataSource ?? LocalInformationDataSource();

  final LocalInformationDataSource _dataSource;

  Future<List<InformationItem>> getItems() => _dataSource.loadItems();
}
