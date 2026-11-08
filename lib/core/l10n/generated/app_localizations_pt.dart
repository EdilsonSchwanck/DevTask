import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'DevTask';

  @override
  String get splashTagline => 'Planeje. Acompanhe. Conclua.';

  @override
  String get splashLoading => 'Carregando suas tarefas…';

  @override
  String get navDashboard => 'Painel';

  @override
  String get navTasks => 'Tarefas';

  @override
  String get navHistory => 'Histórico';

  @override
  String get themeLight => 'Modo claro';

  @override
  String get themeDark => 'Modo escuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageSheetSubtitle => 'Escolha como o DevTask fala com você';

  @override
  String get languageSystemSubtitle => 'Segue o idioma do aparelho';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get dashboardHeadline => 'Veja como estão suas tarefas';

  @override
  String get newTask => 'Nova tarefa';

  @override
  String get editTask => 'Editar tarefa';

  @override
  String get statTotal => 'Total';

  @override
  String get statPending => 'Pendentes';

  @override
  String get statCompleted => 'Concluídas';

  @override
  String get statOverdue => 'Atrasadas';

  @override
  String get completionRate => 'Taxa de conclusão';

  @override
  String completionSummary(int completed, int total, num favorites) {
    final intl.NumberFormat favoritesNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String favoritesString = favoritesNumberFormat.format(favorites);

    String _temp0 = intl.Intl.pluralLogic(
      favorites,
      locale: localeName,
      other: '$favoritesString favoritos',
      one: '1 favorito',
      zero: 'nenhum favorito',
    );
    return '$completed de $total concluídas · $_temp0';
  }

  @override
  String get byCategory => 'Por categoria';

  @override
  String get upNext => 'Próximas';

  @override
  String get nothingPendingTitle => 'Nada pendente';

  @override
  String get nothingPendingMessage =>
      'Toque em + para planejar sua próxima tarefa.';

  @override
  String get searchHint => 'Buscar por título';

  @override
  String get clearSearch => 'Limpar busca';

  @override
  String get noTasksTitle => 'Nenhuma tarefa ainda';

  @override
  String get noTasksMessage => 'Crie sua primeira tarefa com o botão +.';

  @override
  String get noMatchesTitle => 'Nenhuma tarefa encontrada';

  @override
  String get noMatchesMessage => 'Tente outro filtro ou termo de busca.';

  @override
  String get filterAll => 'Todas';

  @override
  String get filterPending => 'Pendentes';

  @override
  String get filterCompleted => 'Concluídas';

  @override
  String get filterOverdue => 'Atrasadas';

  @override
  String get filterFavorites => 'Favoritas';

  @override
  String get historyEmptyTitle => 'Nenhuma tarefa concluída ainda';

  @override
  String get historyEmptyMessage =>
      'As tarefas que você concluir aparecerão aqui.';

  @override
  String historyGroupHeader(String day, int count) {
    return '$day · $count';
  }

  @override
  String historyItemSubtitle(String category, String priority) {
    return '$category · prioridade $priority';
  }

  @override
  String get reopen => 'Reabrir';

  @override
  String overdueOn(String date) {
    return 'Atrasada · $date';
  }

  @override
  String get addFavorite => 'Adicionar aos favoritos';

  @override
  String get removeFavorite => 'Remover dos favoritos';

  @override
  String get priorityLow => 'Baixa';

  @override
  String get priorityMedium => 'Média';

  @override
  String get priorityHigh => 'Alta';

  @override
  String get categoryWork => 'Trabalho';

  @override
  String get categoryStudy => 'Estudos';

  @override
  String get categoryPersonal => 'Pessoal';

  @override
  String get categoryHealth => 'Saúde';

  @override
  String get categoryOther => 'Outros';

  @override
  String get titleLabel => 'Título';

  @override
  String get descriptionLabel => 'Descrição (opcional)';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get priorityLabel => 'Prioridade';

  @override
  String get dueDateLabel => 'Prazo';

  @override
  String get noDueDate => 'Sem prazo';

  @override
  String get clearDueDate => 'Remover prazo';

  @override
  String createdOn(String date) {
    return 'Criada em $date';
  }

  @override
  String completedOn(String date) {
    return 'Concluída em $date';
  }

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get createTask => 'Criar tarefa';

  @override
  String get delete => 'Excluir';

  @override
  String get cancel => 'Cancelar';

  @override
  String get deleteDialogTitle => 'Excluir tarefa?';

  @override
  String get deleteDialogMessage => 'Esta ação não pode ser desfeita.';

  @override
  String get feedbackCreated => 'Tarefa criada';

  @override
  String get feedbackUpdated => 'Tarefa atualizada';

  @override
  String get feedbackDeleted => 'Tarefa excluída';

  @override
  String get errorTitleRequired => 'O título é obrigatório.';

  @override
  String errorTitleTooLong(int max) {
    return 'O título deve ter no máximo $max caracteres.';
  }

  @override
  String errorDescriptionTooLong(int max) {
    return 'A descrição deve ter no máximo $max caracteres.';
  }

  @override
  String get errorTaskNotSaved => 'Esta tarefa ainda não foi salva.';

  @override
  String get errorTaskNotFound =>
      'Tarefa não encontrada. Ela pode ter sido excluída.';

  @override
  String get errorStorage => 'Não foi possível acessar o armazenamento local.';
}
