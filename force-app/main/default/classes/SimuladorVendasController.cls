public with sharing class SimuladorVendasController {

    @AuraEnabled
    public static string buscaObjectNameById (String recordId) {
        return String.valueOf(Id.valueOf(recordId).getSObjectType());
    }

    @AuraEnabled
    public static Quote getQuoteAndQuoteLineItemData (String quoteId) {
        List<Quote> retorno = QuoteSelector.getQuotebyQuoteIdSet(new Set<Id>{quoteId});
        return retorno[0];
    }

    @AuraEnabled
    public static List<AgregadoAtivo__c> getAgregadosByQuoteLineItemId (String quoteItemId) {
        List<AgregadoAtivo__c> retorno = AgregadoAtivoSelector.getAgregadosAtivoByQuotLineItemId(quoteItemId);
        return retorno;
    }

    @AuraEnabled
    public static Boolean verificaPermissaoCustos () {
        Permissoes retorno = new Permissoes();
        return retorno.acessoCustosSimuladorVendas;
    }

    @AuraEnabled
    public static AtivoAgregadoAtivo getAssetData (String assetId) {
        AtivoAgregadoAtivo retorno = new AtivoAgregadoAtivo();
        Asset ativo = AssetSelector.getAssetAgregadosById(assetId);
        retorno.ativo = ativo;
        if (!ativo.AgregadosAtivo__r.isEmpty()) {
            Set<String> setAgregadoParentId = createSetAgregadoParentId(ativo.AgregadosAtivo__r);
            retorno.agregadoAtivo = createListAgregadoAtivoParentIdNotInSet(ativo.AgregadosAtivo__r, setAgregadoParentId);
        }
        return retorno;
    }

    public static List<AgregadoAtivo__c> createListAgregadoAtivoParentIdNotInSet (List<AgregadoAtivo__c> agrgAtivoList, Set<String> setAgregadoParentId) {
        List<AgregadoAtivo__c> retorno = new List<AgregadoAtivo__c>();
        for (AgregadoAtivo__c a : agrgAtivoList) {
            if (!setAgregadoParentId.contains(a.AgregadoId__c)) {
                retorno.add(a);
            }
        }
        return retorno;
    }

    public static Set<String> createSetAgregadoParentId (List<AgregadoAtivo__c> agrgAtivoList) {
        Set<String> retorno = new Set<String>();
        for (AgregadoAtivo__c a : agrgAtivoList) {
            if (String.isNotBlank(a.AgregadoId__r.AgregadoPai__c)) {
                retorno.add(a.AgregadoId__r.AgregadoPai__c);
            }
        }
        return retorno;
    }

    @AuraEnabled
    public static Custos getCustoOperacionalComissao (Id assetId, String quoteId) {
        Custos retorno = new Custos();
        Asset ativo = AssetSelector.getAssetById(assetId);
        validaLojaAtivo(ativo);

        List<DadoEmpresa__mdt> mdtList = MetadataSelector.obtainDadoEmpresaByLoja(ativo.Loja__c);
        validaValidaMetadadoLoja(ativo, mdtList);

        DadoEmpresa__mdt mdt = MetadataSelector.obtainDadoEmpresaByLoja(ativo.Loja__c)[0];
        validaLojaUsuario(ativo, mdtList);

        return validaCotacao(ativo, quoteId, mdt);
    }

    private static Custos validaCotacao(Asset ativo, String quoteId, DadoEmpresa__mdt mdt) {
        if (String.isNotBlank(quoteId)) {
            Quote cotacao = QuoteSelector.getQuotebyQuoteId(quoteId);
            validaDeparamentoCotacao(cotacao);
            if (cotacao.Opportunity.Departamento__c == Label.VeiculoNovo || cotacao.Opportunity.Departamento__c == Label.VendaDireta) {
                return custosNovo(mdt);
            } else if (cotacao.Opportunity.Departamento__c == Label.VeiculoUsado) {
                return custosUsado(mdt);
            }
        } else {
            validaTipoEstoque(ativo);
            if (ativo.TipoEstoque__c == Label.AssetTipoEstoqueNovo) {
                return custosNovo(mdt);
            } else if (ativo.TipoEstoque__c == Label.AssetTipoEstoqueUsado) {
                return custosUsado(mdt);
            }
        }
        return new Custos();
    }

    private static void validaDeparamentoCotacao(Quote cotacao) {
        if (
            cotacao.Opportunity.Departamento__c != Label.VeiculoNovo && 
            cotacao.Opportunity.Departamento__c != Label.VendaDireta && 
            cotacao.Opportunity.Departamento__c != Label.VeiculoUsado
        ){
            throw new AuraHandledException('Não a custos para o departamento ' + cotacao.Departamento__c + '.');
        }
    }

    private static void validaTipoEstoque(Asset ativo) {
        if (ativo.TipoEstoque__c != Label.AssetTipoEstoqueNovo && ativo.TipoEstoque__c != Label.AssetTipoEstoqueUsado){
            throw new AuraHandledException('O ativo precisa estar em Novo ou Usado para calcular os custos.');
        }
    }

    private static void validaLojaUsuario(Asset ativo, List<DadoEmpresa__mdt> mdtList) {
        if (String.isBlank(ativo.Loja__c)){
            throw new AuraHandledException('O seu usuário está sem loja cadastrada. Favor contactar o seu administrador.');
        }
    }

    private static void validaValidaMetadadoLoja(Asset ativo, List<DadoEmpresa__mdt> mdtList) {
        if (mdtList.isEmpty()){
            String lojaLabel = Common.getPicklistOptionLabelByValue ('Asset', 'Loja__c', ativo.Loja__c);
            throw new AuraHandledException('Não exite cadastradastro no meta dado de empresa para a loja ' + lojaLabel + ', favor entrar em contato com seu adiministrador!');
        }
    }

    private static void validaLojaAtivo(Asset ativo) {
        if (String.isBlank(ativo.Loja__c)){
            throw new AuraHandledException('O ativo deve estar vinculado a uma loja para a utilização do simulador!');
        }
    }

    public static Custos custosNovo(DadoEmpresa__mdt mdt) {
        Custos retorno = new Custos();
            retorno.comissao = mdt.Comissao__c;
            retorno.desconto = mdt.Desconto__c;
            retorno.lucroBruto = mdt.LucroBruto__c; 
            retorno.margemLiquida = mdt.MargemLiquida__c;
        return retorno;
    }

    public static Custos custosUsado(DadoEmpresa__mdt mdt) {
        Custos retorno = new Custos();
            retorno.comissao = mdt.ComissaoVU__c;
            retorno.desconto = mdt.DescontoVU__c;
            retorno.lucroBruto = mdt.LucroBrutoVU__c;
            retorno.margemLiquida = mdt.MargemLiquidaVU__c;
        return retorno;
    }

    @AuraEnabled
    public static string salvarSimulacao (String dadosSimilacaoJson, String recordId) {
        DadosSimilacao dadosSimulador = (DadosSimilacao) System.JSON.deserialize(dadosSimilacaoJson, DadosSimilacao.class);
        QuoteLineItem qli = QuoteLineitemSelector.obtainQuoteLineItemByQuoteId(recordId)[0];
        updateQuoteLineItemUnitPrice(dadosSimulador, qli);

        Map<Id, AgregadoAtivo__c> agregadoAtivoMap = createAgregadoAtivoAgregadoIdKey(qli.AgregadosAtivo__r);
        List<AgregadoAtivo__c> agregadoAtivoToUpsert = createAgregadoAtivoToUpsert (dadosSimulador.agregadosCotacao, agregadoAtivoMap);
        upsert agregadoAtivoToUpsert;
        
        Set<Id> agregadoAtivoUpdate = createAgregadoAtivoUpdateSetId(agregadoAtivoToUpsert);
        List<AgregadoAtivo__c> agregadoAtivoToDelete = createAgregadoAtivoToDelete(agregadoAtivoMap, agregadoAtivoUpdate);
        delete agregadoAtivoToDelete;
        
        return '';
    }
    
    private static void updateQuoteLineItemUnitPrice(DadosSimilacao dadosSimulador, QuoteLineItem qli) {
        if (qli.UnitPrice != dadosSimulador.precoPublico) {
            QuoteLineItem qliToInsert = new QuoteLineItem(
                Id = qli.Id, 
                UnitPrice = dadosSimulador.precoPublico,
                DescontoReais__c = qli.PrecoAtivo__c != 0 ? qli.PrecoAtivo__c - dadosSimulador.precoPublico : 0
            );
            try {
                update qliToInsert;
            } catch (Exception e) {
                String msg = '';
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                throw new SimuladorVendasException(msg);
            }
        }
    }

    public static List<AgregadoAtivo__c> createAgregadoAtivoToDelete (Map<Id, AgregadoAtivo__c> agregadoAtivoMap, Set<Id> agregadoAtivoUpdate) {
        List<AgregadoAtivo__c> retorno = new List<AgregadoAtivo__c>();
        if (!agregadoAtivoMap.isEmpty()) {
            for (Id acId: agregadoAtivoMap.keySet()) {
                AgregadoAtivo__c ac = agregadoAtivoMap.get(acId);
                if (!agregadoAtivoUpdate.contains(ac.Id)) {
                    retorno.add(new AgregadoAtivo__c(Id = ac.Id));
                }
            }
        }
        return retorno;
    }

    public static List<AgregadoAtivo__c> createAgregadoAtivoToUpsert (List<AgregadosCotacao> agregadosCotacaoList, Map<Id, AgregadoAtivo__c> agregadoAtivoMap) {
        List<AgregadoAtivo__c> retorno = new List<AgregadoAtivo__c>();
        if (!agregadosCotacaoList.isEmpty()) {
            for (AgregadosCotacao ac: agregadosCotacaoList) {
                if (agregadoAtivoMap.containsKey(ac.agregadoId)) {
                    AgregadoAtivo__c aa = agregadoAtivoMap.get(ac.agregadoId);
                    retorno.add(createAgregadoAtivo (ac, aa.Id));
                } else {
                    retorno.add(createAgregadoAtivo (ac, null));
                }
            }
        }
        return retorno;
    }

    public static Set<Id> createAgregadoAtivoUpdateSetId (List<AgregadoAtivo__c> agregadoAtivoToUpsert) {
        Set<Id> retorno = new Set<Id>();
        if (!agregadoAtivoToUpsert.isEmpty()) {
            for (AgregadoAtivo__c a: agregadoAtivoToUpsert) {
                if (a.Id != null) {
                    retorno.add(a.Id);
                }
            }
        }
        return retorno;
    }

    public static AgregadoAtivo__c createAgregadoAtivo (AgregadosCotacao ac, Id agregadoAtivoId) {
        return new AgregadoAtivo__c(
            Id = agregadoAtivoId,
            AgregadoId__c = ac.agregadoId,
            Custo__c = ac.valor,
            ItemLinhaCotacaoId__c = ac.itemLinhaCotacaoId,
            Observacao__c = ac.observacao
        );
    }

    public static Map<Id, AgregadoAtivo__c> createAgregadoAtivoAgregadoIdKey (List<AgregadoAtivo__c> agregadosAtivo) {
        Map<Id, AgregadoAtivo__c> retorno = new Map<Id, AgregadoAtivo__c>();
        if (!agregadosAtivo.isEmpty()) {
            for (AgregadoAtivo__c a: agregadosAtivo) {
                retorno.put(a.AgregadoId__c, a);
            }
        }
        return retorno;
    }

    public class DadosSimilacao {
        public Decimal precoPublico;
        public Decimal valorTotalComAgregados;
        public List<AgregadosCotacao> agregadosCotacao;
    }

    public class AgregadosCotacao {
        public String name;
        public Decimal valor;
        public Boolean deFabrica;
        public Boolean bonus;
        public String agregadoId;
        public String itemLinhaCotacaoId;
        public String observacao;
    }

    public class Custos {
        @AuraEnabled
        public Double comissao;

        @AuraEnabled
        public Double desconto;

        @AuraEnabled
        public Double lucroBruto;

        @AuraEnabled
        public Double margemLiquida;
    }

    public class AtivoAgregadoAtivo {
        @AuraEnabled
        public Asset ativo;

        @AuraEnabled
        public List<AgregadoAtivo__c> agregadoAtivo;
        public AtivoAgregadoAtivo () {
            this.agregadoAtivo = new List<AgregadoAtivo__c>();
        }
    }

    public virtual class SimuladorVendasException extends Exception {}
}