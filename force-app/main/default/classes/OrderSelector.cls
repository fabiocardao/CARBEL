public with sharing class OrderSelector {
    public static List<Order> getOrderByOppIdSet(Set<Id> oppId) {
        return [SELECT Id, OpportunityId, Status FROM Order WHERE OpportunityId IN :oppId];
    }

    public static List<Order> getOrderBySetId(Set<Id> ordsIds) {
        return [SELECT Id, OpportunityId, Status FROM Order WHERE Id IN :ordsIds];
    }

    public static List<Order> getOrderBySetId(Set<String> ordsIds) {
        return [SELECT Id, OpportunityId, Status FROM Order WHERE Id IN :ordsIds];
    }

    public static List<Order> getOrderAccountAndOrderItemByOppIdSet(Set<Id> orderId) {
        return [
            SELECT
                Id,
                Departamento__c,
                Description,
                DataHoraSincronizacao__c,
                Loja__c,
                OpportunityId,
                AccountId,
                Account.Name,
                Account.IdDealer__c,
                Account.BillingStreet,
                Account.BillingCity,
                Account.BillingState,
                Account.BillingPostalCode,
                Account.BillingCountry,
                Account.CPF__c,
                Account.CNPJ__c,
                Account.DataNascimento__c,
                Account.Email__c,
                Account.TelefoneCelular__c,
                Account.Phone,
                Account.RG__c,
                Account.Type,
                Opportunity.DataEntregaVeiculo__c,
                Opportunity.StageName,
                OrderNumber,
                OwnerId,
                Owner.Name,
                SincronizadoComDealer__c,
                Status,
                TotalAmount,
                NumeroPropostaDealer__c,
                NumeroPedidoDealer__c,
                PercentualComissaoFabrica__c,
                Desconto__c,
                DescontoMaximo__c,
                (
                    SELECT
                        Id,
                        FormaPagamento__c,
                        Financeira__c,
                        Financeira__r.Name,
                        NomeTipo__c,
                        TipoFormaPagamento__c,
                        TipoFormaPagamento__r.IncidenciaMargemVeiculo__c,
                        TipoFormaPagamento__r.IdDealer__c,
                        FormaPagamentoDebito__c,
                        FormaPagamentoDebito__r.NomeTipo__c,
                        FormaPagamentoDebito__r.Valor__c,
                        FormaPagamentoDebito__r.Vencimento__c,
                        InstitucaoFinanceira__c,
                        Valor__c,
                        Vencimento__c,
                        ReservaAlienacao__c,
                        ParcelaCoeficiente__r.NumeroParcelas__c,
                        PlanoFinanceira__r.Name,
                        ModeloVeiculo__r.Name,
                        Placa__c,
                        Cor__c,
                        AnoFabricacao__c,
                        AnoModelo__c,
                        toLabel(Combustivel__c),
                        Observacoes__c
                    FROM FormasPagamento__r
                )
            FROM Order
            WHERE Id IN :orderId
        ];
    }

    public static Order getOrderAccountOrderItemFormaPagamentoByOppId(Id orderId) {
        return [
            SELECT
                Id,
                IdDealer__c,
                CodigoExterno__c,
                AnoFabricacaoVeiculoTroca__c,
                AnoModeloVeiculoTroca__c,
                ChassiVeiculoTroca__c,
                CombustivelVeiculoTroca__c,
                CorVeiculoTroca__c,
                CreatedDate,
                Estoque__c,
                Departamento__c,
                Description,
                KmVeiculoTroca__c,
                Loja__c,
                ModeloVeiculoTroca__c,
                ModeloVeiculoTroca__r.IdDealer__c,
                ModeloVeiculoTroca__r.Marca__c,
                ModeloVeiculoTroca__r.CodigoExterno__c,
                ModeloVeiculoTroca__r.MarcaProduto__r.IdDealer__c,
                ModeloVeiculoTroca__r.MarcaProduto__r.CodigoExterno__c,
                ModeloVeiculoTroca__r.ProdutoPai__r.IdDealer__c,
                ModeloVeiculoTroca__r.ProdutoPai__r.CodigoExterno__c,
                NumeroPedidoDealer__c,
                NumeroPropostaDealer__c,
                NomeVeiculoTroca__c,
                OpportunityId,
                Opportunity.AccountId,
                Opportunity.Account.Name,
                Opportunity.Account.IdDealer__c,
                Opportunity.Account.CodigoExterno__c,
                Opportunity.Account.BillingStreet,
                Opportunity.Account.BillingCity,
                Opportunity.Account.BillingState,
                Opportunity.Account.BillingPostalCode,
                Opportunity.Account.BillingCountry,
                Opportunity.Account.CPF__c,
                Opportunity.Account.CNPJ__c,
                Opportunity.Account.DataNascimento__c,
                Opportunity.Account.Email__c,
                Opportunity.Account.TelefoneCelular__c,
                Opportunity.Account.RG__c,
                Opportunity.DataEntregaVeiculo__c,
                Opportunity.StageName,
                OrderNumber,
                OwnerId,
                Owner.Name,
                PlacaVeiculoTroca__c,
                PrevisaoVenda__c,
                RenavamVeiculoTroca__c,
                Status,
                TotalAmount,
                VaiUtilizarVeiculoNaTroca__c,
                ValoravAliacao__c,
                ValorDesejadoPeloCliente__c,
                DataValidadePedido__c,
                DataValidadeProposta__c,
                PercentualComissaoFabrica__c,
                RecordType.Name,
                RecordTypeId,
                RecordType.DeveloperName,
                (
                    SELECT
                        Id,
                        Name,
                        Agencia__c,
                        Banco__c,
                        Conta__c,
                        ContaConsorcio__c,
                        DescricaoAvaliacaoVeiculo__c,
                        Financeira__c,
                        Financeira__r.IdDealer__c,
                        Financeira__r.CodigoExterno__c,
                        FormaPagamento__c,
                        FormaPagamentoDebito__c,
                        FormaPagamentoDebito__r.TipoFormaPagamento__r.CodigoExterno__c,
                        TipoFormaPagamento__c,
                        TipoFormaPagamento__r.CodigoExterno__c,
                        TipoFormaPagamento__r.IdDealer__c,
                        TipoFormaPagamento__r.IncidenciaMargemVeiculo__c,
                        GrupoConsorcio__c,
                        InstitucaoFinanceira__c,
                        NumeroDocumento__c,
                        Observacoes__c,
                        ParcelaCoeficiente__c,
                        ParcelaCoeficiente__r.IdDealer__c,
                        ParcelaCoeficiente__r.CodigoExterno__c,
                        ParcelaCoeficiente__r.Coeficiente__c,
                        ParcelaCoeficiente__r.NumeroParcelas__c,
                        PlanoFinanceira__c,
                        PlanoFinanceira__r.Name,
                        PlanoFinanceira__r.IdDealer__c,
                        PlanoFinanceira__r.CodigoExterno__c,
                        Valor__c,
                        Vencimento__c,
                        ValorCliente__c,
                        Renavam__c,
                        Placa__c,
                        KmVeiculo__c,
                        ModeloVeiculo__r.IdDealer__c,
                        ModeloVeiculo__r.Marca__c,
                        ModeloVeiculo__r.MarcaProduto__r.IdDealer__c,
                        ModeloVeiculo__r.ProdutoPai__r.IdDealer__c,
                        ModeloVeiculo__r.CodigoExterno__c,
                        ModeloVeiculo__r.MarcaProduto__r.CodigoExterno__c,
                        ModeloVeiculo__r.ProdutoPai__r.CodigoExterno__c,
                        NomeTipo__c,
                        Cor__c,
                        Combustivel__c,
                        Chassi__c,
                        AnoModelo__c,
                        AnoFabricacao__c,
                        UFPlaca__c,
                        IdAvaliacao__c,
                        CodigoCor__c,
                        DescricaoCor__c
                    FROM FormasPagamento__r
                ),
                (
                    SELECT
                        Id,
                        Description,
                        Ativo__c,
                        Ativo__r.Name,
                        Ativo__r.IdDealer__c,
                        Ativo__r.CodigoExterno__c,
                        Ativo__r.AnoFabricacao__c,
                        Ativo__r.AnoModelo__c,
                        Ativo__r.Chassi__c,
                        Ativo__r.CodigoCor__c,
                        Ativo__r.Combustivel__c,
                        Ativo__r.Cor__c,
                        Ativo__r.Marca__c,
                        Ativo__r.NomeVeiculo__c,
                        Ativo__r.Opcionais__c,
                        Ativo__r.Placa__c,
                        Ativo__r.Potencia__c,
                        Product2Id,
                        Product2.CodigoExterno__c,
                        Product2.IdDealer__c,
                        Product2.AnoFabricacao__c,
                        Product2.AnoModelo__c,
                        Product2.Combustivel__c,
                        Product2.MarcaProduto__r.CodigoExterno__c,
                        Product2.MarcaProduto__r.IdDealer__c,
                        Product2.ProdutoPai__r.CodigoExterno__c,
                        Product2.ProdutoPai__r.IdDealer__c,
                        Ativo__r.Renavam__c,
                        Ativo__r.Status,
                        Ativo__r.TipoVeiculo__c,
                        OpportunityLineItemId__c,
                        AnoModeloVendaDireta__c,
                        UnitPrice,
                        ValorOpcionais__c,
                        ValorUnitario__c,
                        CodigoCorVendaDireta__c,
                        Order.RecordTypeId
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

    public static Order getOrderById(Id orderId) {
        return [
            SELECT Id, AlterarAguardando__c, ErroRetornoReabertura__c, SincronizadoComDealer__c, CodigoExterno__c, IdDealer__c, Status, Loja__c
            FROM Order
            WHERE Id = :orderId
        ];
    }

    public static List<Order> getOrderByIdOpp(Id oppId) {
        return [
            SELECT Id, AlterarAguardando__c, OpportunityId, ErroRetornoReabertura__c, SincronizadoComDealer__c, CodigoExterno__c, IdDealer__c, Status, Loja__c
            FROM Order
            WHERE OpportunityId = :oppId AND SincronizadoComDealer__c = false AND Status != 'CANCELADO'
        ];
    }

    public static List<Order> getOrderFormaPagamentoAndOrderItemByCodigoExternoSet(Set<String> codigoExternoSet) {
        return [
            SELECT
                Id,
                CodigoExterno__c,
                Departamento__c,
                Loja__c,
                OpportunityId,
                OrderNumber,
                OwnerId,
                Owner.Name,
                Status,
                TotalAmount,
                DataFaturamento__c,
                DataValidadePedido__c,
                DataValidadeProposta__c,
                Pricebook2Id,
                (
                    SELECT
                        Id,
                        Agencia__c,
                        Banco__c,
                        Conta__c,
                        ContaConsorcio__c,
                        Financeira__c,
                        FormaPagamento__c,
                        GrupoConsorcio__c,
                        InstitucaoFinanceira__c,
                        ParcelaCoeficiente__c,
                        PlanoFinanceira__c,
                        Valor__c,
                        Vencimento__c
                    FROM FormasPagamento__r
                ),
                (SELECT Id, Ativo__c, Product2Id, UnitPrice, Desconto__c, OpportunityLineItemId__c FROM OrderItems)
            FROM Order
            WHERE CodigoExterno__c IN :codigoExternoSet
        ];
    }

    public static Order getOrderFormaPagamentoOrderId(String orderId) {
        return [
            SELECT
                Id,
                CodigoExterno__c,
                Departamento__c,
                Estoque__c,
                Loja__c,
                OpportunityId,
                OrderNumber,
                OwnerId,
                Owner.Name,
                Status,
                TotalAmount,
                ValoravAliacao__c,
                Account.SincronizadoComDealer__c,
                (
                    SELECT
                        Id,
                        Valor__c,
                        Vencimento__c,
                        TipoFormaPagamento__c,
                        TipoFormaPagamento__r.CodigoExterno__c,
                        TipoFormaPagamento__r.IdDealer__c,
                        TipoFormaPagamento__r.IncidenciaMargemVeiculo__c,
                        FormaPagamento__c
                    FROM FormasPagamento__r
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

    public static List<Order> getOrderFormaPagamentoByOwnerIdSetDataFaturamento(
        Set<String> ownerIdSet,
        Datetime inicio,
        Datetime fim,
        Set<String> tipoFormaPagamentoSet
    ) {
        return [
            SELECT
                Id,
                CodigoExterno__c,
                DataFaturamento__c,
                Departamento__c,
                Estoque__c,
                Loja__c,
                OpportunityId,
                OrderNumber,
                OwnerId,
                Owner.Name,
                Status,
                TotalAmount,
                ValoravAliacao__c,
                Account.SincronizadoComDealer__c,
                (
                    SELECT
                        Id,
                        Valor__c,
                        Vencimento__c,
                        TipoFormaPagamento__c,
                        TipoFormaPagamento__r.CodigoExterno__c,
                        TipoFormaPagamento__r.IdDealer__c,
                        TipoFormaPagamento__r.IncidenciaMargemVeiculo__c,
                        FormaPagamento__c
                    FROM FormasPagamento__r
                    WHERE TipoFormaPagamento__r.IdDealer__c IN :tipoFormaPagamentoSet
                )
            FROM Order
            WHERE OwnerId IN :ownerIdSet AND DataFaturamento__c >= :inicio AND DataFaturamento__c <= :fim
        ];
    }

    public static List<Order> getAllTodayOrderByDepartamentoStatusLoja(Set<String> departamentoSet, Set<String> statusSet, String loja) {
        return [
            SELECT Id, OpportunityId, Status
            FROM Order
            WHERE Departamento__c IN :departamentoSet AND Status IN :statusSet AND Loja__c = :loja AND CreatedDate = TODAY
        ];
    }

    public static List<Order> obterPedidosDiferenteReprovadoCancelado(Set<Id> idsOportunidades, Set<String> statusSet) {
        return [SELECT Id, Status, OpportunityId, DataEntrega__c FROM Order WHERE OpportunityId IN :idsOportunidades AND Status NOT IN :statusSet];
    }

    public static List<Order> getOrderByStatusOppIdSetAndNotOrderIdSet(Set<String> status, Set<String> oppId, Set<String> orderId) {
        return [SELECT Id, OpportunityId, Status FROM Order WHERE Status IN :status AND OpportunityId IN :oppId AND Id NOT IN :orderId];
    }

    public static List<Order> getOrderIndividualByOrderList(List<Order> orderList) {
        return [
            SELECT
                Id,
                Departamento__c,
                Marca__c,
                Account.RecordTypeId,
                Account.PersonIndividualId,
                Account.ContatoPrincipal__c,
                Account.ContatoPrincipal__r.IndividualId
            FROM Order
            WHERE Id IN :orderList
        ];
    }

    public static List<Order> getOrderAccountOrderOrdersItemByOppId(Id oppId) {
        return [
            SELECT
                Id,
                IdDealer__c,
                CodigoExterno__c,
                AnoFabricacaoVeiculoTroca__c,
                AnoModeloVeiculoTroca__c,
                ChassiVeiculoTroca__c,
                CombustivelVeiculoTroca__c,
                CorVeiculoTroca__c,
                CreatedDate,
                Estoque__c,
                Departamento__c,
                Description,
                KmVeiculoTroca__c,
                Loja__c,
                ModeloVeiculoTroca__c,
                ModeloVeiculoTroca__r.IdDealer__c,
                ModeloVeiculoTroca__r.Marca__c,
                ModeloVeiculoTroca__r.CodigoExterno__c,
                ModeloVeiculoTroca__r.MarcaProduto__r.IdDealer__c,
                ModeloVeiculoTroca__r.MarcaProduto__r.CodigoExterno__c,
                ModeloVeiculoTroca__r.ProdutoPai__r.IdDealer__c,
                ModeloVeiculoTroca__r.ProdutoPai__r.CodigoExterno__c,
                NumeroPedidoDealer__c,
                NumeroPropostaDealer__c,
                NomeVeiculoTroca__c,
                OpportunityId,
                Opportunity.AccountId,
                Opportunity.Account.Name,
                Opportunity.Account.IdDealer__c,
                Opportunity.Account.CodigoExterno__c,
                Opportunity.Account.BillingStreet,
                Opportunity.Account.BillingCity,
                Opportunity.Account.BillingState,
                Opportunity.Account.BillingPostalCode,
                Opportunity.Account.BillingCountry,
                Opportunity.Account.CPF__c,
                Opportunity.Account.CNPJ__c,
                Opportunity.Account.DataNascimento__c,
                Opportunity.Account.Email__c,
                Opportunity.Account.TelefoneCelular__c,
                Opportunity.Account.RG__c,
                Opportunity.DataEntregaVeiculo__c,
                Opportunity.StageName,
                OrderNumber,
                OwnerId,
                Owner.Name,
                PlacaVeiculoTroca__c,
                PrevisaoVenda__c,
                RenavamVeiculoTroca__c,
                Status,
                TotalAmount,
                VaiUtilizarVeiculoNaTroca__c,
                ValoravAliacao__c,
                ValorDesejadoPeloCliente__c,
                DataValidadePedido__c,
                DataValidadeProposta__c,
                PercentualComissaoFabrica__c,    
                RecordType.DeveloperName,            
                (
                    SELECT
                        Id,
                        Description,
                        Ativo__c,
                        Ativo__r.Name,
                        Ativo__r.IdDealer__c,
                        Ativo__r.CodigoExterno__c,
                        Ativo__r.AnoFabricacao__c,
                        Ativo__r.AnoModelo__c,
                        Ativo__r.Chassi__c,
                        Ativo__r.CodigoCor__c,
                        Ativo__r.Combustivel__c,
                        Ativo__r.Cor__c,
                        Ativo__r.Marca__c,
                        Ativo__r.NomeVeiculo__c,
                        Ativo__r.Opcionais__c,
                        Ativo__r.Placa__c,
                        Ativo__r.Potencia__c,
                        Product2Id,
                        Product2.CodigoExterno__c,
                        Product2.IdDealer__c,
                        Product2.Name,
                        Product2.AnoFabricacao__c,
                        Product2.AnoModelo__c,
                        Product2.Combustivel__c,
                        Product2.MarcaProduto__r.CodigoExterno__c,
                        Product2.MarcaProduto__r.IdDealer__c,
                        Product2.ProdutoPai__r.CodigoExterno__c,
                        Product2.ProdutoPai__r.IdDealer__c,
                        Ativo__r.Renavam__c,
                        Ativo__r.Status,
                        Ativo__r.TipoVeiculo__c,
                        OpportunityLineItemId__c,
                        Order.RecordTypeId,
                        UnitPrice,
                        ValorOpcionais__c,
                        ValorUnitario__c,
                        CodigoCorVendaDireta__c,
                        AnoModeloVendaDireta__c
                    FROM OrderItems
                )
            FROM Order
            WHERE OpportunityId = :oppId AND Status != 'CANCELADO' AND Status != 'FATURADO' AND Status != 'Sincronizado'];
    }

    public static List<String> obterProdutosComPedido(Set<String> IdsOli){
        List<OrderItem> itemsComProduto = [SELECT Id, OpportunityLineItemId__c, Order.Status FROM OrderItem WHERE OpportunityLineItemId__c IN: IdsOli AND Order.Status != 'CANCELADO' ];
        List<String> listPodutoComPedido = new List<String>();

        for(OrderItem itemComProduto : itemsComProduto){
            listPodutoComPedido.add(itemComProduto.OpportunityLineItemId__c);
        }
        System.debug(listPodutoComPedido);
        return listPodutoComPedido;
    }

    public static List<Order> getEventsInOrder(Set<Id> orderId){
        return [
            SELECT 
                Id, 
                DataEntrega__c, 
                (
                    SELECT 
                    Id, 
                    Subject, 
                    type, 
                    Status__c 
                    FROM Events
                ) 
            FROM Order 
            WHERE Id in :orderId
            ];
    }
    
}