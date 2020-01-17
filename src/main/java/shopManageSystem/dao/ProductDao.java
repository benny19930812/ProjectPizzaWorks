package shopManageSystem.dao;

import java.util.List;

import org.hibernate.SessionFactory;

import _model.ProductBean;
import _model.RecipeBean;
import _model.SalesOrderBean;

public interface ProductDao {

	void setFactory(SessionFactory factory);

	List<ProductBean> getAllProducts();

	// 供網站管理員修改商品上架否之方法
	void updateOneProduct(ProductBean pb);

	ProductBean getProductById(Integer productId);

	
	List<SalesOrderBean> getAllSalesOrders();
	void updateOneRecipe(RecipeBean recipe);

	void updateOneRecipeJson(Double quantity, Integer productId, Integer materialsId);


	SalesOrderBean getSalesOrderById(Integer salesOrderId);

}