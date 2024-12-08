public inherited sharing class OrderItemSelector {
    
    public static List<OrderItem> getOrderItemByOrderIdSet (Set<Id> orderId) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                Ativo__r.Loja__c,
                Ativo__r.IdDealer__c,
                OpportunityLineItemId__c, 
                OrderId,
                Order.OpportunityId,
                Order.Status,
                Order.Opportunity.AccountId,
                Order.Opportunity.StageName
            FROM OrderItem 
            WHERE OrderId IN: orderId
        ];
    }

    public static List<OrderItem> getOrderItemAndAgregadosByOrderIdPdf (String orderId) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                Ativo__r.IdDealer__c,
                Ativo__r.AnoFabricacao__c,
                Ativo__r.AnoModelo__c,
                Ativo__r.Chassi__c,
                toLabel(Ativo__r.Combustivel__c),
                Ativo__r.Cor__c,
                toLabel(Ativo__r.Marca__c),
                Ativo__r.NomeVeiculo__c,
                Ativo__r.DescricaoOpcionais__c,
                Ativo__r.Placa__c,
                Ativo__r.Potencia__c,
                Ativo__r.Renavam__c,
                Ativo__r.Status,
                Ativo__r.TipoVeiculo__c,
                Ativo__r.EmTransito__c,
                Ativo__r.Product2.NomeVeiculo__c,
                Product2Id,
                Product2.AnoFabricacao__c,
                Product2.AnoModelo__c,
                toLabel(Product2.Combustivel__c),
                toLabel(Product2.Marca__c),
                Product2.NomeVeiculo__c,
                Product2.Potencia__c,
                Product2.TipoVeiculo__c,
                Order.Departamento__c,
                (SELECT 
                    id,
                    AgregadoId__r.Name
                FROM AgregadosAtivo__r)
            FROM OrderItem 
            WHERE OrderId =: orderId
        ];
    }

    public static List<OrderItem> getOrderItemByAssetId (Set<Id> assetsId) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                OpportunityLineItemId__c, 
                OrderId,
                Order.Status,
                Order.IdDealer__c,
                Order.EffectiveDate,
                toLabel(Order.Loja__c),
                Order.Owner.Name,
                Order.OrderNumber,
                Order.DataValidadePedido__c,
                Order.DataValidadeProposta__c
            FROM OrderItem 
            WHERE Ativo__c IN: assetsId
        ];
    }
    
    public static List<OrderItem> getOrderItemByAssetIdAndOrderStatusSet (Set<String> assetsId, Set<String> status) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                OpportunityLineItemId__c, 
                OrderId,
                Order.Status,
                Product2Id,
                Ativo__r.Status,
                Order.DataValidadePedido__c,
                Order.DataValidadeProposta__c
            FROM OrderItem 
            WHERE Ativo__c IN: assetsId
            AND Order.Status IN: status
        ];
    }

    public static List<OrderItem> getOrderItemByOrderStatusComAtivo (Set<String> status) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                OpportunityLineItemId__c, 
                OrderId,
                Order.Status
            FROM OrderItem 
            WHERE Order.Status IN: status
            AND Ativo__c != null
        ];
    }
    
    public static List<OrderItem> getOrderItemByAssetWithoutSetIds (Set<Id> assetsId, Set<Id> listIds) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                OpportunityLineItemId__c, 
                OrderId
            FROM OrderItem 
            WHERE Ativo__c IN: assetsId
            AND OpportunityLineItemId__c NOT IN : listIds
        ];
    }
    
    public static Decimal obtainOrderItemCountPedido() {
        return [ 
            SELECT
                COUNT()
            FROM OrderItem
            WHERE OrderId IN (
                                SELECT Id
                                FROM Order
                                WHERE NumeroPedidoDealer__c != null
                                AND Status NOT IN (:Label.OrderStatusCancelado, :Label.OrderStatusFaturado, :Label.OrderStatusReprovado))
            AND Ativo__c != null
        ];
    }

    public static Decimal obtainOrderItemCountProposta() {
        return [ 
            SELECT
                COUNT()
            FROM OrderItem
            WHERE OrderId IN (
                SELECT Id
                FROM Order
                WHERE NumeroPedidoDealer__c = null
                AND Status NOT IN (:Label.OrderStatusCancelado, :Label.OrderStatusFaturado, :Label.OrderStatusReprovado))
            AND Ativo__c != null
        ];
    }

    public static List<OrderItem> obtainOrderItemByOrderIdSet (Set<Id> orderIdSet) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                Ativo__r.Loja__c,
                OpportunityLineItemId__c, 
                OrderId
            FROM OrderItem 
            WHERE OrderId IN : orderIdSet
        ];
    }

    public static List<OrderItem> obtainOrderItemToRemoveAsset (Set<Id> orderItemIdSet, Set<Id> assetIdSet) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                OrderId,
                Order.OpportunityId
            FROM OrderItem 
            WHERE Id NOT IN: orderItemIdSet
            AND Ativo__c IN: assetIdSet
        ];
    }

    public static List<OrderItem> obtainOrderItemAndAgregadosByOrderItemId (Set<String> orderItemIdSet) {
        return [
            SELECT 
                Id, 
                Ativo__c,
                Ativo__r.CodigoExterno__c,
                Desconto__c,
                OpportunityLineItemId__c,
                OrderId,
                Order.CodigoExterno__c,
                Order.Departamento__c,
                PricebookEntryId,
                Product2Id,
                Quantity,
                UnitPrice,
                (SELECT Id, Custo__c, AgregadoId__c, AgregadoId__r.CodigoExterno__c, ProdutoPedidoId__c  From AgregadosAtivo__r)
            FROM OrderItem 
            WHERE Id IN: orderItemIdSet
        ];
    }

    public static List<OrderItem> getOrderItemByAssetIdAndOrder(String assetId, String orderId) {
        String query = 
            'SELECT '
                + 'Id, '
                + 'Ativo__c, '
                + 'OrderId, '
                + 'Order.DataValidadePedido__c, '
                + 'Order.DataValidadeProposta__c '
            + ' FROM OrderItem '
            + ' WHERE Ativo__c = \'' + assetId + '\''
            + ' AND OrderId != \'' + orderId + '\''
            + ' AND (OrderItem.Order.DataValidadePedido__c > ' + Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.sss-03:00')
            + ' OR OrderItem.Order.DataValidadeProposta__c > ' + Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.sss-03:00')
            + ')';
        return Database.query(query);    
    }
}