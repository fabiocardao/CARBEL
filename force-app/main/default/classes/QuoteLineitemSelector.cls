public inherited sharing class QuoteLineitemSelector {
    public static List<QuoteLineItem> obtainQuoteLineItemByQuoteId(String cotacaoId) {
        return [
            SELECT
                Id,
                Ativo__c,
                UnitPrice,
                PrecoAtivo__c,
                DescontoReais__c,
                QuoteId,
                Quote.EntradaReais__c,
                Quote.FormaPagamento__c,
                (SELECT Id, AgregadoId__c, Custo__c, ItemLinhaCotacaoId__c FROM AgregadosAtivo__r)
            FROM QuoteLineItem
            WHERE QuoteId = :cotacaoId
        ];
    }

    public static List<QuoteLineItem> getQuoteItemBySetAssetsIdNotSetOppId(Set<Id> assetsId, Set<Id> oppId) {
        return [
            SELECT Ativo__c, DescontoReais__c, Quote.OpportunityId, Product2Id, UnitPrice
            FROM QuoteLineItem
            WHERE Ativo__c IN :assetsId AND Quote.OpportunityId NOT IN :oppId
        ];
    }

    public static List<QuoteLineItem> obtainQuoteLineItemFieldsByQuoteId(String qliFields, String quoteIds) {
        String qliQuery =
            'select Id, QuoteId, PricebookEntryId, OpportunityLineItemId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' +
            qliFields +
            ' from QuoteLineItem where QuoteId in (' +
            quoteIds +
            ') order by QuoteId, SortOrder ASC';
        return Database.query(qliQuery);
    }
}